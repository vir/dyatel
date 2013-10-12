
-- sample data
BEGIN WORK;
INSERT INTO ipnetworks(net, id) VALUES ('192.168.0/17', 1);
INSERT INTO ipnetworks(net, id) VALUES ('192.168.48/24', 2);
INSERT INTO ipnetworks(net, id) VALUES ('10.0.0/24', 1);
INSERT INTO users (num, alias, domain, password, descr) VALUES ('222', 'vir',  'voip.ctm.ru', '222', 'vir test spa962');
INSERT INTO users (num, alias, domain, password, descr) VALUES ('223', 'vir2', 'voip.ctm.ru', '223', 'vir test2');
INSERT INTO users (num, domain, password, descr) SELECT s::TEXT, 'voip.ctm.ru', s::TEXT, 'test user ' || s::TEXT FROM generate_series(224, 229) AS s;
INSERT INTO provision (uid, hw, devtype, params) VALUES ((SELECT id FROM USERS LIMIT 1), '000E08D48EB4', 'linksys-spa', 'number => one');

INSERT INTO ivr_aa(num, descr, prompt, timeout, e1, e2, e3, etimeout) VALUES (
	'222', 'Sample auto-attendant', '/home/vir/menu.au', 5,
	'115', '106', '223', '496');

INSERT INTO ivr_minidisa(num, descr, prompt, timeout, numlen, firstdigit, etimeout) VALUES (
	'223', 'Sample auto-attendant', '/home/vir/disa.au', 15, 3, '123', '222');

INSERT INTO abbrs (num, target, descr) VALUES ('666', '+79210000001', 'xxx mobile');
INSERT INTO abbrs (num, owner, target, descr) VALUES ('#1', 189, '+79210000002', 'some other mobile');

COMMIT;

