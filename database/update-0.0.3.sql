
ALTER DOMAIN phone DROP NOT NULL;

CREATE TABLE ivr_aa(
	id SERIAL PRIMARY KEY, num PHONE NOT NULL,
	descr TEXT, prompt TEXT, timeout INTEGER,
	e0 PHONE, e1 PHONE, e2 PHONE, e3 PHONE,
	e4 PHONE, e5 PHONE, e6 PHONE, e7 PHONE,
	e8 PHONE, e9 PHONE, estar PHONE, ehash PHONE,
	etimeout PHONE
);

CREATE TABLE ivr_minidisa(
	id SERIAL PRIMARY KEY, num PHONE NOT NULL,
	descr TEXT, prompt TEXT, timeout INTEGER,
	numlen INTEGER NOT NULL DEFAULT 3,
	firstdigit VARCHAR(12),
	etimeout PHONE
);

