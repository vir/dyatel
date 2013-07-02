
-- sample data
INSERT INTO ipnetworks(net, id) VALUES ('192.168.0/17', 1);
INSERT INTO ipnetworks(net, id) VALUES ('192.168.48/24', 2);
INSERT INTO ipnetworks(net, id) VALUES ('10.0.0/24', 1);
INSERT INTO users (num, alias, password, descr) VALUES ('222', 'vir', '222', 'vir test spa962');
INSERT INTO users (num, alias, password, descr) VALUES ('223', 'vir2', '223', 'vir test2');
INSERT INTO users (num, domain, password, descr) SELECT s::TEXT, 'voip.ctm.ru', s::TEXT, 'test user ' || s::TEXT FROM generate_series(224, 229) AS s;

