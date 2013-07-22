
-- sample data
BEGIN WORK;
INSERT INTO ipnetworks(net, id) VALUES ('192.168.0/17', 1);
INSERT INTO ipnetworks(net, id) VALUES ('192.168.48/24', 2);
INSERT INTO ipnetworks(net, id) VALUES ('10.0.0/24', 1);
INSERT INTO users (num, alias, domain, password, descr) VALUES ('222', 'vir',  'voip.ctm.ru', '222', 'vir test spa962');
INSERT INTO users (num, alias, domain, password, descr) VALUES ('223', 'vir2', 'voip.ctm.ru', '223', 'vir test2');
INSERT INTO users (num, domain, password, descr) SELECT s::TEXT, 'voip.ctm.ru', s::TEXT, 'test user ' || s::TEXT FROM generate_series(224, 229) AS s;
INSERT INTO provision (uid, hw, devtype, params) VALUES (9, '000E08D48EB4', 'linksys-spa', 'number => one');
COMMIT;

