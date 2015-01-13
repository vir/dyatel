
-- sample data
BEGIN WORK;

INSERT INTO config (section, params, ts, uid) VALUES ('schedule', '"mode_override"=>"hzhz"', '2014-02-28 16:03:18.471943+04', 189);
INSERT INTO config (section, params, ts, uid) VALUES ('ui', '"language"=>"ru"', '2014-03-13 23:42:12.880679+04', 189);
INSERT INTO config (section, params, ts, uid) VALUES ('route', '"debug"=>"true", "schedule_override"=>""', '2014-03-14 06:22:03.983468+04', 189);


INSERT INTO ipnetworks(net, id) VALUES ('192.168.0/17',  1);
INSERT INTO ipnetworks(net, id) VALUES ('192.168.48/24', 2);
INSERT INTO ipnetworks(net, id) VALUES ('10.0.0/24',     1);


INSERT INTO fingroups (name) VALUES ('Sales');
INSERT INTO fingroups (name) VALUES ('Accounting');


INSERT INTO directory(num, numtype, descr) VALUES ('222', 'user', 'vir test spa962');
INSERT INTO users (num, alias, domain, password, login, badges, fingrp, secure) VALUES ('222', 'vir', 'voip.ctm.ru', '222', 'vir@ctm.ru', '{admin,finance}', NULL, 'ssl');
INSERT INTO directory(num, numtype, descr) VALUES ('223', 'user', 'vir test2');
INSERT INTO users (num, alias, domain, password, login, badges, fingrp, secure) VALUES ('223', 'vir2', 'voip.ctm.ru', '223', NULL, '{}', 2, 'on');
INSERT INTO directory(num, numtype, descr) SELECT s::TEXT, 'user', 'test user ' || s::TEXT FROM generate_series(224, 229) AS s;
INSERT INTO users (num, domain, password, fingrp) SELECT s::TEXT, 'voip.ctm.ru', s::TEXT, 1 FROM generate_series(224, 229) AS s;


INSERT INTO directory(num, numtype, descr) VALUES ('822', 'ivr', 'Sample auto-attendant');
INSERT INTO ivr_aa(num, prompt, timeout, e1, e2, e3, etimeout) VALUES (
	'822', '/home/vir/menu.au', 5,
	'115', '106', '223', '496');


INSERT INTO directory(num, numtype, descr) VALUES ('823', 'ivr', 'Sample auto-attendant 2');
INSERT INTO ivr_minidisa(num, prompt, timeout, numlen, firstdigit, etimeout) VALUES (
	'823', '/home/vir/disa.au', 15, 3, '123', '222');


INSERT INTO directory(num, numtype, descr) VALUES ('666', 'abbr', 'xxx mobile');
INSERT INTO abbrs (num, target) VALUES ('666', '+79210000001');
INSERT INTO directory(num, numtype, descr) VALUES ('#1', 'abbr', 'some other mobile');
INSERT INTO abbrs (num, owner, target) VALUES ('#1', (SELECT id FROM users WHERE num = '222'), '+79210000002');


INSERT INTO incoming(ctx, called, mode, route) VALUES ('from_outside', NULL,      NULL,      '888');
INSERT INTO incoming(ctx, called, mode, route) VALUES ('from_outside', '3259753', NULL,      '887');
INSERT INTO incoming(ctx, called, mode, route) VALUES ('from_outside', NULL,      'evening', '889');
INSERT INTO incoming(ctx, called, mode, route) VALUES ('from_outside', NULL,      'night',   '886');
INSERT INTO incoming(ctx, called, mode, route) VALUES ('from_outside', NULL,      'work',    '885');


INSERT INTO morenums(uid, numkind, val, div_noans, div_offline) VALUES ((SELECT id FROM users WHERE num = '222'), 1, '+7-921-1234567', true, false);
INSERT INTO morenums(uid, numkind, val, div_noans, div_offline) VALUES ((SELECT id FROM users WHERE num = '222'), 2, '+7-812-1234567', true, true );


INSERT INTO blfs (uid, key, num, label) VALUES (1, '1', '224', NULL);
INSERT INTO blfs (uid, key, num, label) VALUES (1, '4', '223', NULL);
INSERT INTO blfs (uid, key, num, label) VALUES (1, '5', '+79213131113', 'cell');
INSERT INTO blfs (uid, key, num, label) VALUES (1, '7', '+78125858390', 'нет нигде');
INSERT INTO blfs (uid, key, num, label) VALUES (1, '8', '5010', NULL);
INSERT INTO blfs (uid, key, num, label) VALUES (1, '9', '5001', NULL);


INSERT INTO phonebook (id, owner, num, descr, comments, numkind) VALUES (1, NULL, '666223', 'pb-vir test2', 'Comment for vir test2', NULL);
INSERT INTO phonebook (id, owner, num, descr, comments, numkind) VALUES (2, NULL, '666224', 'pb-test user 224', 'Comment for test user 224', NULL);
INSERT INTO phonebook (id, owner, num, descr, comments, numkind) VALUES (3, NULL, '666226', 'pb-test user 226', 'Comment for test user 226', NULL);
INSERT INTO phonebook (id, owner, num, descr, comments, numkind) VALUES (4, NULL, '666227', 'pb-test user 227', 'Comment for test user 227', NULL);
INSERT INTO phonebook (id, owner, num, descr, comments, numkind) VALUES (5, NULL, '666228', 'pb-test user 228', 'Comment for test user 228', NULL);
INSERT INTO phonebook (id, owner, num, descr, comments, numkind) VALUES (6, NULL, '666229', 'pb-test user 229', 'Comment for test user 229', NULL);
INSERT INTO phonebook (id, owner, num, descr, comments, numkind) VALUES (15, NULL, '666108', 'pb-Учебная', 'Comment for Учебная', NULL);
INSERT INTO phonebook (id, owner, num, descr, comments, numkind) VALUES (17, NULL, '666225', 'pb-test user 225', 'Comment for test user 225', NULL);
INSERT INTO phonebook (id, owner, num, descr, comments, numkind) VALUES (28, NULL, '666222', 'pb-vir test spa962', 'Comment for vir test spa962', NULL);
INSERT INTO phonebook (id, owner, num, descr, comments, numkind) VALUES (30, NULL, '666144', 'pb-test user 144', 'Comment for test user 144', NULL);


INSERT INTO provision (uid, hw, devtype, params) VALUES (1, '00:0e:08:d4:8e:b4', 'linksys-spa504g', '"number"=>"one"');
INSERT INTO provision (uid, hw, devtype, params) VALUES (2, '58:bf:ea:11:11:de', 'linksys-spa502g', NULL);
INSERT INTO provision (uid, hw, devtype, params) VALUES (3, '58:bf:ea:11:11:e7', 'linksys-spa502g', NULL);
INSERT INTO provision (uid, hw, devtype, params) VALUES (4, '58:bf:ea:11:11:e8', 'linksys-spa502g', NULL);
INSERT INTO provision (uid, hw, devtype, params) VALUES (5, '58:bf:ea:11:11:f3', 'linksys-spa502g', NULL);
INSERT INTO provision (uid, hw, devtype, params) VALUES (6, '58:bf:ea:11:11:fc', 'linksys-spa502g', NULL);
INSERT INTO provision (uid, hw, devtype, params) VALUES (7, '58:bf:ea:11:11:fd', 'linksys-spa502g', NULL);
INSERT INTO provision (uid, hw, devtype, params) VALUES (8, '64:9e:f3:79:4b:9c', 'linksys-spa502g', NULL);


INSERT INTO vcards (uid, vcard) VALUES (2, '<vCard xmlns="vcard-temp">
<FN>Test 223</FN>
<NICKNAME>t_223</NICKNAME>
</vCard>');


INSERT INTO queues (id, mintime, length, maxout, greeting, onhold, maxcall, prompt, notify, detail, single) VALUES (1, 500, 0, -1, NULL, NULL, NULL, NULL, NULL, true, false);


INSERT INTO directory (num, numtype, descr) VALUES ('5000', 'callgrp', 'Test BIG group ');
INSERT INTO directory (num, numtype, descr) VALUES ('5001', 'callgrp', 'Test Group SUPPORT');
INSERT INTO directory (num, numtype, descr) VALUES ('5002', 'callgrp', 'Test Group 3');
INSERT INTO directory (num, numtype, descr) VALUES ('5003', 'callgrp', 'Test Fourth group');
INSERT INTO callgroups (num, distr, rotary_last, ringback, maxcall, exitpos, queue) VALUES ('5000', 'parallel', 0, 'tone/ring', 20000, NULL, NULL);
INSERT INTO callgroups (num, distr, rotary_last, ringback, maxcall, exitpos, queue) VALUES ('5001', 'parallel', 0, 'tone/ring', 60000, '266', NULL);
INSERT INTO callgroups (num, distr, rotary_last, ringback, maxcall, exitpos, queue) VALUES ('5002', 'parallel', 0, NULL, 0, NULL, 1);
INSERT INTO callgroups (num, distr, rotary_last, ringback, maxcall, exitpos, queue) VALUES ('5003', 'parallel', 0, NULL, 0, NULL, NULL);

INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (1, 1, '222', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (1, 2, '223', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (1, 3, '224', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (1, 4, '225', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (1, 5, '226', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (1, 6, '227', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (1, 7, '228', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (1, 8, '229', true);

INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (2, 1, '222', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (2, 2, '223', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (2, 3, '224', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (2, 4, '225', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (2, 5, '226', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (2, 6, '227', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (2, 7, '228', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (2, 8, '229', true);

INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (3, 1, '222', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (3, 2, '223', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (3, 3, '224', true);

INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (4, 1, '222', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (4, 2, '223', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (4, 3, '224', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (4, 4, '225', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (4, 5, '226', true);
INSERT INTO callgrpmembers (grp, ord, num, enabled) VALUES (4, 6, '227', true);


INSERT INTO pickupgroups (id, callgrepcopy, descr) VALUES (1, NULL, 'Test PickupGroup 1');

INSERT INTO pickupgrpmembers(grp, uid) VALUES (1, 1);
INSERT INTO pickupgrpmembers(grp, uid) VALUES (1, 2);
INSERT INTO pickupgrpmembers(grp, uid) VALUES (1, 3);
INSERT INTO pickupgrpmembers(grp, uid) VALUES (1, 4);
INSERT INTO pickupgrpmembers(grp, uid) VALUES (1, 5);
INSERT INTO pickupgrpmembers(grp, uid) VALUES (1, 6);
INSERT INTO pickupgrpmembers(grp, uid) VALUES (1, 7);


INSERT INTO schedule(prio,                  tstart, tend, mode) VALUES ( 0,                                 '00:00', '24:00', 'holiday');
INSERT INTO schedule(prio,             dow, tstart, tend, mode) VALUES (10,                  '{1,2,3,4,5}', '09:00', '18:00', 'work');
INSERT INTO schedule(prio,             dow, tstart, tend, mode) VALUES (20,                  '{1,2,3,4,5}', '18:00', '21:00', 'evening');
INSERT INTO schedule(prio,             dow, tstart, tend, mode) VALUES (30,                  '{1,2,3,4,5}', '21:00', '24:00', 'night');
INSERT INTO schedule(prio,             dow, tstart, tend, mode) VALUES (30,                  '{1,2,3,4,5}', '00:00', '09:00', 'night');
INSERT INTO schedule(      mday, days,      tstart, tend, mode) VALUES (    '2013-12-31', 9,                 '0:00', '24:00', 'holiday');


INSERT INTO regs(userid, ts, location, expires, device, driver, ip_transport, ip_host, ip_port, audio, route_params) VALUES (1, 'now()', '222@voip.ctm.ru/Yate',                             'now'::TIMESTAMP WITH TIME ZONE + '1 hour'::INTERVAL, NULL, 'jabber', NULL, '192.168.67.222', 23882, true, NULL);
INSERT INTO regs(userid, ts, location, expires, device, driver, ip_transport, ip_host, ip_port, audio, route_params) VALUES (1, 'now()', '223@voip.ctm.ru/Psi+',                             'now'::TIMESTAMP WITH TIME ZONE + '1 hour'::INTERVAL, NULL, 'jabber', NULL, '192.168.67.220', 1883, true, NULL);
INSERT INTO regs(userid, ts, location, expires, device, driver, ip_transport, ip_host, ip_port, audio, route_params) VALUES (1, 'now()', '222@voip.ctm.ru/660f6dfeb76bd5c4b86c233fc5fca4db', 'now'::TIMESTAMP WITH TIME ZONE + '1 hour'::INTERVAL, NULL, 'jabber', NULL, '192.168.67.222', 27716, true, NULL);
INSERT INTO regs(userid, ts, location, expires, device, driver, ip_transport, ip_host, ip_port, audio, route_params) VALUES (1, 'now()', 'somewhere',                                        'now'::TIMESTAMP WITH TIME ZONE + '1 hour'::INTERVAL, NULL, 'hands', NULL, NULL, NULL, true, NULL);
INSERT INTO regs(userid, ts, location, expires, device, driver, ip_transport, ip_host, ip_port, audio, route_params) VALUES (2, 'now()', '223@voip.ctm.ru/a13131a6316fc01cae1f8e79936c31b2', 'now'::TIMESTAMP WITH TIME ZONE + '1 hour'::INTERVAL, NULL, 'jabber', NULL, '192.168.67.220', 4334, true, NULL);
INSERT INTO regs(userid, ts, location, expires, device, driver, ip_transport, ip_host, ip_port, audio, route_params) VALUES (2, 'now()', '223@voip.ctm.ru/bc4244be85e614bceffb92119042837e', 'now'::TIMESTAMP WITH TIME ZONE + '1 hour'::INTERVAL, NULL, 'jabber', NULL, '192.168.67.220', 4370, true, NULL);
INSERT INTO regs(userid, ts, location, expires, device, driver, ip_transport, ip_host, ip_port, audio, route_params) VALUES (2, 'now()', '223@voip.ctm.ru/3291b21f0567ec3dde269efd001ef178', 'now'::TIMESTAMP WITH TIME ZONE + '1 hour'::INTERVAL, NULL, 'jabber', NULL, '192.168.67.220', 2135, true, NULL);
INSERT INTO regs(userid, ts, location, expires, device, driver, ip_transport, ip_host, ip_port, audio, route_params) VALUES (3, 'now()', 'somwhere/far/away',                                'now'::TIMESTAMP WITH TIME ZONE + '1 hour'::INTERVAL, NULL, 'hands', NULL, NULL, NULL, true, NULL);
INSERT INTO regs(userid, ts, location, expires, device, driver, ip_transport, ip_host, ip_port, audio, route_params) VALUES (4, 'now()', 'smewhere',                                         'now'::TIMESTAMP WITH TIME ZONE + '1 hour'::INTERVAL, NULL, 'hands', NULL, NULL, NULL, true, NULL);


INSERT INTO linetracker (uid, direction, status, chan, caller, called, billid) VALUES (1, 'incoming', 'answered', 'sip/951', '165',     '989052693929',   '1390584592-639');
INSERT INTO linetracker (uid, direction, status, chan, caller, called, billid) VALUES (1, 'incoming', 'answered', 'sip/393', '100',     '192',            '1390584592-666');
INSERT INTO linetracker (uid, direction, status, chan, caller, called, billid) VALUES (1, 'outgoing', 'ringing',  'sip/666', '100',     '200',            '1390584592-zzz');
INSERT INTO linetracker (uid, direction, status, chan, caller, called, billid) VALUES (2, 'outgoing', 'answered', 'sip/966', '6666666', '1390584592-777', NULL);
INSERT INTO linetracker (uid, direction, status, chan, caller, called, billid) VALUES (3, 'outgoing', 'ringing',  'sip/393', '100',     '192',            '1390584592-yyy');
INSERT INTO linetracker (uid, direction, status, chan, caller, called, billid) VALUES (4, 'outgoing', 'ringing',  'sip/916', '+7777',   '1390584592-111', NULL);


INSERT INTO prices (pref, price, descr) VALUES ('8818',     4.6500001,  'Архангельская област');
INSERT INTO prices (pref, price, descr) VALUES ('81037517', 8.89999962, 'Беларусь');
INSERT INTO prices (pref, price, descr) VALUES ('8915',     4.96000004, 'Брянская область');
INSERT INTO prices (pref, price, descr) VALUES ('8473',     4.96000004, 'Воронеж');
INSERT INTO prices (pref, price, descr) VALUES ('8717',     8.68000031, 'Казахстан');
INSERT INTO prices (pref, price, descr) VALUES ('8721',     8.68000031, 'Казахстан');
INSERT INTO prices (pref, price, descr) VALUES ('8727',     8.68000031, 'Казахстан');
INSERT INTO prices (pref, price, descr) VALUES ('8923',     6.19999981, 'Красноярский край');
INSERT INTO prices (pref, price, descr) VALUES ('81037167', 8.06000042, 'Латвия');
INSERT INTO prices (pref, price, descr) VALUES ('81037129', 8.06000042, 'Латвия, Моб.');
INSERT INTO prices (pref, price, descr) VALUES ('8813',     2.78999996, 'Ленинградская област');
INSERT INTO prices (pref, price, descr) VALUES ('8495',     1.24000001, 'Москва');
INSERT INTO prices (pref, price, descr) VALUES ('8499',     1.24000001, 'Москва');
INSERT INTO prices (pref, price, descr) VALUES ('8903',     1.24000001, 'Московская область');
INSERT INTO prices (pref, price, descr) VALUES ('8831',     4.96000004, 'Нижегородская област');
INSERT INTO prices (pref, price, descr) VALUES ('8383',     6.19999981, 'Новосибирск');
INSERT INTO prices (pref, price, descr) VALUES ('8814',     4.6500001,  'Петрозаводск');
INSERT INTO prices (pref, price, descr) VALUES ('8811',     4.6500001,  'Псков');
INSERT INTO prices (pref, price, descr) VALUES ('8811',     4.6500001,  'Псковская область');
INSERT INTO prices (pref, price, descr) VALUES ('8911',     4.6500001,  'Псковская область');
INSERT INTO prices (pref, price, descr) VALUES ('8814',     4.6500001,  'Республика Карелия');
INSERT INTO prices (pref, price, descr) VALUES ('8921',     4.6500001,  'Республика Карелия');
INSERT INTO prices (pref, price, descr) VALUES ('8916',     1.24000001, 'Россия мобильные ост');
INSERT INTO prices (pref, price, descr) VALUES ('81099871', 8.68000031, 'Узбекистан');
INSERT INTO prices (pref, price, descr) VALUES ('81038044', 8.68000031, 'Украина');
INSERT INTO prices (pref, price, descr) VALUES ('8346',     6.19999981, 'Ханты−Мансийский АО');
INSERT INTO prices (pref, price, descr) VALUES ('8351',     6.19999981, 'Челябинск');
INSERT INTO prices (pref, price, descr) VALUES ('8878',     4.96000004, 'Черкесск');
INSERT INTO prices (pref, price, descr) VALUES ('81037261', 8.06000042, 'Эстония');
INSERT INTO prices (pref, price, descr) VALUES ('81037255', 8.06000042, 'Эстония, Моб.');
INSERT INTO prices (pref, price, descr) VALUES ('8343',     6.19999981, 'Екатеринбург');

COMMIT;





