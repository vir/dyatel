
CREATE TABLE provision (
	uid INTEGER REFERENCES users(id) ON DELETE CASCADE,
	hw MACADDR,
	devtype TEXT,
	params HSTORE
);

