CREATE TABLE `test_positions` (
  `id` int(11) not null auto_increment,
  `ticker_id` int(11) NOT NULL DEFAULT '0',
  `ettime` datetime DEFAULT NULL,
  `etprice` float DEFAULT NULL,
  `etival` float DEFAULT NULL,
  `xttime` datetime DEFAULT NULL,
  `xtprice` float DEFAULT NULL,
  `xtival` float DEFAULT NULL,
  `entry_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `entry_price` float DEFAULT NULL,
  `entry_ival` float DEFAULT NULL,
  `exit_date` datetime DEFAULT NULL,
  `exit_price` float DEFAULT NULL,
  `exit_ival` float DEFAULT NULL,
  `days_held` int(11) DEFAULT NULL,
  `nreturn` float DEFAULT NULL,
  `logr` float DEFAULT NULL,
  `short` tinyint(1) DEFAULT NULL,
  `closed` tinyint(1) DEFAULT NULL,
  `entry_pass` int(11) DEFAULT NULL,
  `roi` float DEFAULT NULL,
  `num_shares` int(11) DEFAULT NULL,
  `etind_id` int(11) DEFAULT NULL,
  `xtind_id` int(11) DEFAULT NULL,
  `entry_trigger_id` int(11) DEFAULT NULL,
  `entry_strategy_id` int(11) DEFAULT NULL,
  `exit_trigger_id` int(11) DEFAULT NULL,
  `exit_strategy_id` int(11) DEFAULT NULL,
  `scan_id` int(11) DEFAULT NULL,
  `consumed_margin` float DEFAULT NULL,
  `eind_id` int(11) DEFAULT NULL,
  `xind_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY index_on_ticker_id_and_entry_date (`ticker_id`,`entry_date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1
 PARTITION BY linear hash (id)
 PARTITIONS  10;
/*
(PARTITION p0 VALUES LESS THAN (2000) ENGINE = MyISAM,
 PARTITION p1 VALUES LESS THAN (2001) ENGINE = MyISAM,
 PARTITION p2 VALUES LESS THAN (2002) ENGINE = MyISAM,
 PARTITION p3 VALUES LESS THAN (2003) ENGINE = MyISAM,
 PARTITION p4 VALUES LESS THAN (2004) ENGINE = MyISAM,
 PARTITION p5 VALUES LESS THAN (2005) ENGINE = MyISAM,
 PARTITION p6 VALUES LESS THAN (2006) ENGINE = MyISAM,
 PARTITION p7 VALUES LESS THAN (2007) ENGINE = MyISAM,
 PARTITION p8 VALUES LESS THAN (2008) ENGINE = MyISAM,
 PARTITION p9 VALUES LESS THAN (2009) ENGINE = MyISAM,
 PARTITION p10 VALUES LESS THAN (2010) ENGINE = MyISAM,
 PARTITION p11 VALUES LESS THAN (2011) ENGINE = MyISAM,
 PARTITION p12 VALUES LESS THAN MAXVALUE ENGINE = MyISAM);
*/