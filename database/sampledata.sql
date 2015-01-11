
-- sample data
BEGIN WORK;

INSERT INTO ipnetworks(net, id) VALUES ('192.168.0/17', 1);
INSERT INTO ipnetworks(net, id) VALUES ('192.168.48/24', 2);
INSERT INTO ipnetworks(net, id) VALUES ('10.0.0/24', 1);

INSERT INTO fingroups (name) VALUES ('Sales');
INSERT INTO fingroups (name) VALUES ('Accounting');

INSERT INTO directory(num, numtype, descr) VALUES ('222', 'user', 'vir test spa962');
INSERT INTO users (num, alias, domain, password, login, badges, fingrp, secure) VALUES ('222', 'vir', 'voip.ctm.ru', '222', 'vir@ctm.ru', '{admin,finance}', NULL, 'ssl');
INSERT INTO directory(num, numtype, descr) VALUES ('223', 'user', 'vir test2');
INSERT INTO users (num, alias, domain, password, login, badges, fingrp, secure) VALUES ('223', 'vir2', 'voip.ctm.ru', '223', NULL, '{}', 2, 'on');
INSERT INTO directory(num, numtype, descr) SELECT s::TEXT, 'user', 'test user ' || s::TEXT FROM generate_series(224, 229) AS s;
INSERT INTO users (num, domain, password, fingrp) SELECT s::TEXT, 'voip.ctm.ru', s::TEXT, 1 FROM generate_series(224, 229) AS s;

INSERT INTO provision (uid, hw, devtype, params) VALUES ((SELECT id FROM USERS ORDER BY id LIMIT 1), '000E08D48EB4', 'linksys-spa', 'number => one');

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

INSERT INTO schedule (prio,      tstart, tend, mode) VALUES ( 0,                '00:00', '24:00', 'holiday');
INSERT INTO schedule (prio, dow, tstart, tend, mode) VALUES (10, '{1,2,3,4,5}', '09:00', '18:00', 'work');
INSERT INTO schedule (prio, dow, tstart, tend, mode) VALUES (20, '{1,2,3,4,5}', '18:00', '21:00', 'evening');
INSERT INTO schedule (prio, dow, tstart, tend, mode) VALUES (30, '{1,2,3,4,5}', '21:00', '24:00', 'night');
INSERT INTO schedule (prio, dow, tstart, tend, mode) VALUES (30, '{1,2,3,4,5}', '00:00', '09:00', 'night');
INSERT INTO schedule (mday, days, tstart, tend, mode) VALUES ('2013-12-31', 9, '0:00', '24:00', 'holiday');

INSERT INTO incoming(ctx, route) VALUES ('from_outside', '888');
INSERT INTO incoming(ctx, called, route) VALUES ('from_outside', '3259753', '887');
INSERT INTO incoming(ctx, mode, route) VALUES ('from_outside', 'evening', '889');
INSERT INTO incoming(ctx, mode, route) VALUES ('from_outside', 'night', '886');
INSERT INTO incoming(ctx, mode, route) VALUES ('from_outside', 'work', '885');

INSERT INTO morenums(uid, numkind, val) VALUES ((SELECT id FROM users WHERE num = '222'), 1, '+7-921-1234567');
INSERT INTO morenums(uid, numkind, val) VALUES ((SELECT id FROM users WHERE num = '222'), 2, '+7-812-1234567');

INSERT INTO blfs (uid, key, num, label) VALUES (1, '1', '224', NULL);
INSERT INTO blfs (uid, key, num, label) VALUES (1, '4', '223', NULL);
INSERT INTO blfs (uid, key, num, label) VALUES (1, '5', '+79213131113', 'cell');
INSERT INTO blfs (uid, key, num, label) VALUES (1, '7', '+78125858390', 'нет нигде');
INSERT INTO blfs (uid, key, num, label) VALUES (1, '8', '5010', NULL);
INSERT INTO blfs (uid, key, num, label) VALUES (1, '9', '5001', NULL);

COMMIT;


