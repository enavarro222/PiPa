#!/usr/bin/env python
#-*- coding:utf-8 -*-
import sys
import logging

from datetime import datetime, timedelta
import time
import calendar

import requests

import pandas as pd

class EmoncmsClient(object):
    """ Get data from emoncms API
    """

    def __init__(self, url, apikey=None):
        self._logger = logging.getLogger("EmoncmsClient")
        self.url = url
        self.apikey = apikey

    def _get_json(self, url, params=None):
        if params is None:
            params = self._default_params()
        results = requests.get(url, params=params)
        # error if not 200 for HTTP status
        results.raise_for_status()
        if results.text == "false":
            raise RuntimeError("Impossible to get the data (%s)" % results.url)
        self._logger.debug("query: %s" % results.url)
        return results.json()

    def _default_params(self):
        params = {}
        if self.apikey is not None:
            params["apikey"] = self.apikey
        return params

    def feeds(self):
        """ Get data about all available feeds
        """
        res = self._get_json(self.url + "/feed/list.json")  #XXX: userid=1 to get public data (to check)
        for feed in res:
            feed["id"] = int(feed["id"])
            feed["date"] = datetime.fromtimestamp(feed["time"])
        return res

    def get_value(self, fid):
        """ return the last value of a field
        """
        all_data = self.feeds()
        all_data = {feed["id"]: feed for feed in all_data}
        if fid not in all_data:
            raise ValueError("Feed not found")
        return all_data[fid]

    def _check_interval(self, delta_sec, start_date=None, end_date=None, nb_data=None):
        """ check inputs, set defaults

        >>> emon = EmoncmsClient("http://localhost/")
        >>> # if not given end_date will be now
        >>> delta_sec, start_date, nb_data = emon._check_interval(60)
        >>> nb_data # default value
        100
        >>> (datetime.now() - start_date).total_seconds() - delta_sec*nb_data < 1
        True
        >>> # else start_time is computed from other params
        >>> delta_sec, start_date, nb_data = emon._check_interval(60*60, end_date=datetime(2015, 2, 11), nb_data=48)
        >>> start_date.isoformat()
        '2015-02-09T00:00:00'
        """
        default_nb_data = 100
        if start_date is not None and end_date is not None:
            if nb_data is not None:
                raise ValueError("End and start date are given , you can not set nb_data")
            nb_data = (end_date - start_date).total_seconds() / delta_sec
        if start_date is None:
            if end_date is None:
                self._logger.info("Set end_time to now (default)")
                end_date = datetime.now()
            if nb_data is None:
                self._logger.info("Set nb_data to 100 (default)")
                nb_data = default_nb_data
            start_date = end_date - timedelta(0, nb_data*delta_sec)
        return delta_sec, start_date, nb_data

    def get_data(self, fid, delta_sec, start_date=None, end_date=None, nb_data=None):
        """
        :param fid: feed ID to get
        """
        # search for feed
        for feed in self.feeds():
            if fid == feed['id']:
                feed_name = feed['name']
                break
        else:
            raise ValueError("Field %s is unknow" % fid)

        delta_sec, start_date, nb_data = self._check_interval(
            delta_sec=delta_sec,
            start_date=start_date,
            end_date=end_date,
            nb_data=nb_data
        )
        ## make the requests
        t_start = time.mktime( start_date.timetuple() )*1000
        #t_start = calendar.timegm(start_date.timetuple())*1000
        
        # get datas
        data_brut = []
        nb_read = 0
        nb_each_request = 800
        while nb_read < nb_data:
            # choix du pas de temps
            nb_to_read = min(nb_each_request, nb_data-nb_read)
            t_end = t_start + nb_to_read*delta_sec*1000
            #rint  int( t_start ), int( t_end )
            query = self.url + "/feed/average.json"
            params = self._default_params()
            params["id"] = fid
            params["start"] = "%d" % t_start
            params["end"] = "%d" % t_end
            params["interval"] = delta_sec
            
            data_brut += self._get_json(query, params)
            nb_read += nb_to_read
            t_start = data_brut[-1][0]
        
        ## convert it to panda
        dates, vals = zip(*data_brut)
        dates = [datetime.fromtimestamp(date/1000) for date in dates]
        ts = pd.Series(vals, index=dates, name=feed_name)
        return ts


def main():
    import matplotlib.pyplot as plt
    import argparse
    parser = argparse.ArgumentParser()
    
    parser.add_argument("-u", "--url", action='store', type=str, help="emoncms root url")
    parser.add_argument("-k", "--api-key",
        action='store', type=str,
        help="API key (get public data if not given)", default=None
    )
    parser.add_argument("-f", "--feed-id", action='store', type=int, help="Feed ID")

    args = parser.parse_args()

    # Build emoncms data source object
    emon_src = EmoncmsSource(args.url, apikey=args.api_key)

    ## list all feed
    from pprint import pprint
    print("#"*5 + " ALL FEEDS  " + "#"*5)
    feeds = emon_src.feeds()
    for feed in feeds:
        print("* id:{id:<3} name:{name:<16} value:{value:<10} last update:{date}".format(**feed))

    ## Plot one feed
    if args.feed_id:
        print("#"*5 + " PLOT  " + "#"*5)
        start_date = datetime(2014, 9, 10)
        delta_sec = 60*5
        ts = emon_src.get_data(args.feed_id, start_date, delta_sec, nb_data=10000)
        ts.plot()
        plt.show()

    return 0

if __name__ == '__main__':
    sys.exit(main())


