BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "address" (
	"id"	INTEGER NOT NULL UNIQUE,
	"address"	TEXT NOT NULL DEFAULT 0,
	"city"	TEXT NOT NULL DEFAULT '',
	"state"	TEXT NOT NULL DEFAULT '',
	"zip"	TEXT NOT NULL DEFAULT '',
	"country"	TEXT NOT NULL DEFAULT '',
	"createdby"	INTEGER NOT NULL DEFAULT '',
	"disabled"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "company" (
	"id"	INTEGER NOT NULL DEFAULT 1 UNIQUE,
	"addressid"	INTEGER NOT NULL DEFAULT '',
	"name"	TEXT NOT NULL DEFAULT '',
	"email"	TEXT NOT NULL DEFAULT '',
	"officephone"	TEXT NOT NULL DEFAULT '',
	"cellphone"	TEXT NOT NULL DEFAULT '',
	"plustax"	INTEGER DEFAULT '0',
	"fax"	TEXT NOT NULL DEFAULT '',
	"website"	TEXT NOT NULL DEFAULT '',
	"notes"	TEXT NOT NULL DEFAULT '',
	"createdby"	INTEGER NOT NULL DEFAULT 0,
	"disabled"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "contacts" (
	"id"	INTEGER NOT NULL UNIQUE,
	"addressid"	INTEGER NOT NULL DEFAULT '',
	"title"	TEXT NOT NULL DEFAULT '',
	"name"	TEXT NOT NULL DEFAULT '',
	"email"	TEXT NOT NULL DEFAULT '',
	"officephone"	TEXT NOT NULL DEFAULT '',
	"cellphone"	TEXT NOT NULL DEFAULT '',
	"fax"	TEXT NOT NULL DEFAULT '',
	"website"	TEXT NOT NULL DEFAULT '',
	"notes"	TEXT NOT NULL DEFAULT '',
	"createdby"	INTEGER NOT NULL DEFAULT '',
	"companyid"	INTEGER NOT NULL DEFAULT 0,
	"disabled"	INTEGER NOT NULL DEFAULT 0,
	"cccontact"	INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "contracttype" (
	"id"	INTEGER NOT NULL DEFAULT '0' UNIQUE,
	"title"	TEXT NOT NULL DEFAULT '',
	"terms"	TEXT NOT NULL DEFAULT '',
	"rate"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "costs" (
	"id"	INTEGER NOT NULL UNIQUE,
	"name"	TEXT NOT NULL DEFAULT '',
	"longname"	TEXT NOT NULL DEFAULT '',
	"multiplier"	INTEGER NOT NULL DEFAULT 0.10,
	"createdby"	INTEGER NOT NULL DEFAULT '0',
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "dispatch" (
	"id"	INTEGER NOT NULL DEFAULT 0 UNIQUE,
	"equipmentid"	INTEGER NOT NULL DEFAULT 0,
	"addressid"	INTEGER NOT NULL DEFAULT 0,
	"contactid"	INTEGER NOT NULL DEFAULT 0,
	"date"	INTEGER NOT NULL DEFAULT 0,
	"reportedissue"	TEXT NOT NULL DEFAULT '',
	"status"	INTEGER NOT NULL DEFAULT 0,
	"reportedby"	TEXT NOT NULL DEFAULT '',
	"contact"	TEXT NOT NULL DEFAULT '',
	"notes"	TEXT NOT NULL DEFAULT '',
	"data"	TEXT NOT NULL DEFAULT '',
	"hourlyrate"	INTEGER NOT NULL DEFAULT 0,
	"travelrate"	INTEGER NOT NULL DEFAULT 0,
	"contracttype"	INTEGER NOT NULL DEFAULT 0,
	"worktype"	INTEGER NOT NULL DEFAULT 1,
	"createdby"	INTEGER NOT NULL DEFAULT 0,
	"disabled"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "equipment" (
	"id"	TEXT NOT NULL UNIQUE,
	"name"	TEXT NOT NULL DEFAULT '',
	"addressid"	INTEGER NOT NULL DEFAULT '',
	"contactid"	INTEGER NOT NULL DEFAULT '',
	"typeid"	INTEGER NOT NULL DEFAULT 0,
	"sn"	TEXT NOT NULL DEFAULT '',
	"notes"	TEXT NOT NULL DEFAULT '',
	"createdby"	INTEGER NOT NULL DEFAULT '',
	"disabled"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "formfields" (
	"id"	INTEGER NOT NULL UNIQUE,
	"fgrp"	INTEGER NOT NULL,
	"fieldname"	TEXT NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "formfieldtitle" (
	"id"	INTEGER NOT NULL UNIQUE,
	"name"	TEXT NOT NULL DEFAULT '',
	"disabled"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "inventory" (
	"id"	TEXT NOT NULL UNIQUE,
	"name"	TEXT NOT NULL DEFAULT '',
	"shelfid"	INTEGER NOT NULL DEFAULT '0',
	"qty"	INTEGER NOT NULL DEFAULT '0',
	"cost"	INTEGER NOT NULL DEFAULT '0',
	"price"	INTEGER NOT NULL DEFAULT '0',
	"supplierid"	INTEGER NOT NULL DEFAULT '0',
	"supplierpartnumber"	TEXT DEFAULT '',
	"plustax"	INTEGER NOT NULL DEFAULT 0,
	"notes"	TEXT NOT NULL DEFAULT '',
	"createdby"	INTEGER NOT NULL DEFAULT '0',
	"disabled"	INTEGER NOT NULL DEFAULT '0',
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "invoice" (
	"id"	INTEGER NOT NULL DEFAULT 0 UNIQUE,
	"qtid"	INTEGER NOT NULL DEFAULT '',
	"desc"	TEXT NOT NULL DEFAULT '',
	"date"	TEXT NOT NULL DEFAULT '',
	"notes"	TEXT NOT NULL DEFAULT '',
	"createdby"	INTEGER NOT NULL DEFAULT 0,
	"disabled"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "invscope" (
	"id"	INTEGER NOT NULL DEFAULT 0 UNIQUE,
	"invid"	INTEGER NOT NULL DEFAULT 0,
	"dispatchid"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "packingslip" (
	"id"	INTEGER NOT NULL DEFAULT 0 UNIQUE,
	"qtid"	INTEGER NOT NULL DEFAULT '',
	"date"	TEXT NOT NULL DEFAULT '',
	"notes"	TEXT NOT NULL DEFAULT '',
	"createdby"	INTEGER NOT NULL DEFAULT 0,
	"disabled"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "pdfchunks" (
	"id"	INTEGER NOT NULL DEFAULT 0 UNIQUE,
	"chunk"	TEXT DEFAULT '',
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "poinv" (
	"id"	INTEGER NOT NULL DEFAULT '0' UNIQUE,
	"inventoryid"	INTEGER NOT NULL DEFAULT '0',
	"qtid"	INTEGER NOT NULL DEFAULT '0',
	"qty"	INTEGER NOT NULL DEFAULT '0',
	"cost"	INTEGER NOT NULL DEFAULT '0',
	"costsubtotal"	INTEGER NOT NULL DEFAULT 0,
	"costtotal"	INTEGER NOT NULL DEFAULT 0,
	"price"	INTEGER NOT NULL DEFAULT '0',
	"subtotal"	INTEGER NOT NULL DEFAULT 0,
	"total"	INTEGER NOT NULL DEFAULT 0,
	"discountrate"	INTEGER NOT NULL DEFAULT '0',
	"plustax"	INTEGER NOT NULL DEFAULT '0',
	"notes"	TEXT NOT NULL DEFAULT '',
	"createdby"	INTEGER NOT NULL DEFAULT '0',
	"disabled"	INTEGER NOT NULL DEFAULT '0',
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "qtinv" (
	"id"	INTEGER NOT NULL DEFAULT '0' UNIQUE,
	"inventoryid"	INTEGER NOT NULL DEFAULT '0',
	"qtid"	INTEGER NOT NULL DEFAULT '0',
	"qty"	INTEGER NOT NULL DEFAULT '0',
	"cost"	INTEGER NOT NULL DEFAULT '0',
	"costsubtotal"	INTEGER NOT NULL DEFAULT 0,
	"costtotal"	INTEGER NOT NULL DEFAULT 0,
	"plustax"	INTEGER NOT NULL DEFAULT '0',
	"price"	INTEGER NOT NULL DEFAULT '0',
	"subtotal"	INTEGER NOT NULL DEFAULT 0,
	"total"	INTEGER NOT NULL DEFAULT 0,
	"discountrate"	INTEGER NOT NULL DEFAULT '0',
	"notes"	TEXT NOT NULL DEFAULT '',
	"createdby"	INTEGER NOT NULL DEFAULT '0',
	"disabled"	INTEGER NOT NULL DEFAULT '0',
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "qtscope" (
	"id"	INTEGER NOT NULL DEFAULT 0 UNIQUE,
	"typeid"	INTEGER NOT NULL DEFAULT 0,
	"qtid"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "quote" (
	"id"	INTEGER NOT NULL DEFAULT '0' UNIQUE,
	"contracttype"	INTEGER NOT NULL DEFAULT '',
	"quotedesc"	TEXT NOT NULL DEFAULT '',
	"contactid"	INTEGER NOT NULL DEFAULT '0',
	"billingaddressid"	INTEGER NOT NULL DEFAULT '',
	"sitename"	TEXT NOT NULL DEFAULT '',
	"siteaddressid"	INTEGER NOT NULL DEFAULT '',
	"currencyid"	INTEGER NOT NULL DEFAULT '0',
	"costsubtotal"	INTEGER NOT NULL DEFAULT 0,
	"costtotal"	INTEGER NOT NULL DEFAULT 0,
	"subtotal"	INTEGER NOT NULL DEFAULT 0,
	"total"	INTEGER NOT NULL DEFAULT 0,
	"plustax"	INTEGER NOT NULL DEFAULT '0',
	"date"	INTEGER NOT NULL DEFAULT '',
	"hourlyrate"	TEXT NOT NULL DEFAULT '',
	"travelrate"	TEXT NOT NULL DEFAULT '',
	"termsid"	INTEGER NOT NULL DEFAULT '0',
	"data"	TEXT NOT NULL DEFAULT '',
	"expirydate"	INTEGER NOT NULL DEFAULT '',
	"startdate"	INTEGER NOT NULL DEFAULT '',
	"enddate"	INTEGER NOT NULL DEFAULT '',
	"maintenancedate"	INTEGER NOT NULL DEFAULT '',
	"supplierid"	INTEGER NOT NULL DEFAULT '',
	"notes"	TEXT NOT NULL DEFAULT '',
	"createdby"	INTEGER NOT NULL DEFAULT '0',
	"status"	INTEGER NOT NULL DEFAULT 1,
	"disabled"	INTEGER NOT NULL DEFAULT '0',
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "salestaxes" (
	"id"	INTEGER NOT NULL DEFAULT 0 UNIQUE,
	"country"	TEXT NOT NULL DEFAULT '',
	"state"	TEXT NOT NULL DEFAULT '',
	"taxname"	TEXT NOT NULL DEFAULT '',
	"taxrate"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "scf" (
	"id"	INTEGER NOT NULL DEFAULT 0 UNIQUE,
	"scformfields"	INTEGER DEFAULT 0,
	"scfcolid"	INTEGER NOT NULL DEFAULT 0,
	"formfieldtitleid"	INTEGER NOT NULL DEFAULT 0,
	"value"	TEXT NOT NULL DEFAULT 0,
	"scid"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "scformfields" (
	"id"	INTEGER NOT NULL UNIQUE,
	"formfieldtitleid"	INTEGER NOT NULL DEFAULT '',
	"scid"	INTEGER NOT NULL DEFAULT '',
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "scinv" (
	"id"	INTEGER NOT NULL UNIQUE,
	"inventoryid"	INTEGER NOT NULL DEFAULT '',
	"scid"	INTEGER NOT NULL DEFAULT '',
	"userid"	INTEGER NOT NULL DEFAULT '',
	"qty"	INTEGER NOT NULL DEFAULT '',
	"sn"	TEXT NOT NULL DEFAULT '',
	"notes"	TEXT NOT NULL DEFAULT '',
	"date"	TEXT NOT NULL DEFAULT '',
	"createdby"	INTEGER NOT NULL DEFAULT '',
	"disabled"	INTEGER NOT NULL DEFAULT '0',
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "servicecall" (
	"id"	INTEGER NOT NULL UNIQUE,
	"dispatchid"	INTEGER NOT NULL DEFAULT 0,
	"userid"	INTEGER NOT NULL DEFAULT 0,
	"date"	INTEGER NOT NULL DEFAULT '',
	"starttime"	TEXT NOT NULL DEFAULT '09:00',
	"time"	INTEGER NOT NULL DEFAULT 1,
	"traveltime"	INTEGER NOT NULL DEFAULT 1,
	"solution"	TEXT NOT NULL DEFAULT '',
	"data"	TEXT NOT NULL DEFAULT '',
	"workcode"	INTEGER NOT NULL DEFAULT 0,
	"status"	INTEGER NOT NULL DEFAULT 2,
	"createdby"	INTEGER NOT NULL DEFAULT 0,
	"disabled"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "servicecontract" (
	"id"	INTEGER NOT NULL DEFAULT '0' UNIQUE,
	"contracttype"	INTEGER NOT NULL DEFAULT '',
	"hourlyrate"	TEXT NOT NULL DEFAULT '0',
	"travelrate"	TEXT NOT NULL DEFAULT '0',
	"quoteexpirydate"	TEXT NOT NULL DEFAULT '',
	"quoteterms"	TEXT NOT NULL DEFAULT '',
	"startdate"	TEXT NOT NULL DEFAULT '',
	"enddate"	TEXT NOT NULL DEFAULT '',
	"maintenancedate"	TEXT NOT NULL DEFAULT '',
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "shelf" (
	"id"	INTEGER NOT NULL DEFAULT 1 UNIQUE,
	"name"	TEXT NOT NULL DEFAULT 'none',
	"barcode"	INTEGER NOT NULL DEFAULT '11111111' UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "sql_queries" (
	"id"	INTEGER NOT NULL UNIQUE,
	"name"	TEXT NOT NULL UNIQUE,
	"query"	TEXT NOT NULL DEFAULT '',
	"timestamp"	TEXT NOT NULL DEFAULT '',
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "status" (
	"id"	INTEGER NOT NULL UNIQUE,
	"status"	TEXT NOT NULL DEFAULT '',
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "sys_menu" (
	"id"	INTEGER NOT NULL UNIQUE,
	"menuid"	TEXT NOT NULL DEFAULT '',
	"menutext"	TEXT NOT NULL DEFAULT '',
	"nextid"	TEXT NOT NULL DEFAULT '',
	"previd"	TEXT NOT NULL DEFAULT '',
	"readquery"	TEXT NOT NULL DEFAULT '',
	"writequery"	TEXT NOT NULL DEFAULT '',
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "terms" (
	"id"	INTEGER NOT NULL DEFAULT 0 UNIQUE,
	"title"	TEXT NOT NULL DEFAULT '',
	"desc"	TEXT NOT NULL DEFAULT '',
	"createdby"	INTEGER NOT NULL DEFAULT '0',
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "type" (
	"id"	INTEGER NOT NULL UNIQUE,
	"name"	TEXT NOT NULL DEFAULT '',
	"hourlyrate"	INTEGER NOT NULL DEFAULT 0,
	"travelrate"	INTEGER NOT NULL DEFAULT 0,
	"billingcode"	INTEGER NOT NULL DEFAULT 0,
	"createdby"	INTEGER NOT NULL DEFAULT 0,
	"disabled"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL UNIQUE,
	"name"	TEXT NOT NULL DEFAULT '',
	"login"	TEXT NOT NULL DEFAULT '',
	"fullname"	TEXT NOT NULL DEFAULT '',
	"phone"	TEXT NOT NULL DEFAULT '',
	"email"	TEXT NOT NULL DEFAULT '',
	"privilege"	INTEGER NOT NULL DEFAULT 2,
	"password"	TEXT NOT NULL DEFAULT '',
	"trustedip"	TEXT NOT NULL DEFAULT '',
	"menu"	TEXT NOT NULL DEFAULT '',
	"invmode"	INTEGER DEFAULT 'W',
	"invbarcode"	TEXT NOT NULL DEFAULT '11111111',
	"invid"	INTEGER NOT NULL DEFAULT 1,
	"createdby"	INTEGER NOT NULL,
	"disabled"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "userinv" (
	"id"	INTEGER NOT NULL UNIQUE,
	"inventoryid"	INTEGER NOT NULL DEFAULT '',
	"userid"	INTEGER NOT NULL DEFAULT '',
	"qty"	INTEGER NOT NULL DEFAULT '0',
	"date"	TEXT NOT NULL DEFAULT '',
	"notes"	TEXT NOT NULL DEFAULT '',
	"createdby"	INTEGER NOT NULL DEFAULT '',
	"disabled"	INTEGER NOT NULL DEFAULT '0',
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "worktype" (
	"id"	INTEGER NOT NULL DEFAULT 0 UNIQUE,
	"worktype"	TEXT NOT NULL DEFAULT '',
	PRIMARY KEY("id" AUTOINCREMENT)
);
INSERT INTO "address" ("id","address","city","state","zip","country","createdby","disabled") VALUES (0,'123 Fake St.','UNDEFINED','ON','fake','CA',0,0),
 (1,'123 Fake St.','Timmins','ON','P4P0A5','CA',0,0),
 (2,'1 Island','New York','ON','10001','US',0,0);
INSERT INTO "company" ("id","addressid","name","email","officephone","cellphone","plustax","fax","website","notes","createdby","disabled") VALUES (1,3,'Tip the Boat Ltd.','namo@ttb.com','705-555-5551','fff',1,'','','9999ffff9f',0,0),
 (2,5,'Wavve Com','linda@waave.net','778-555-9999','',1,'','','',0,0),
 (3,1,'Boxes & Boxes Inc.','jcox@boxesboxes.com','775-444-1234','775-555-5552',1,'','','',0,0),
 (4,11,'Bright Idea Software Ltd.','rmac@brightidea.com','435-555-5551','435-326-2222',1,'','','',0,0),
 (5,7,'Everest Solutions','ricky@everestsolutions.com','250-000-9000','',1,'','','',0,0),
 (6,3,'Amerson Transport Inc.','aa@amersontransport.com','709-000-8888','',1,'','','',0,0),
 (7,9,'fotomarket','ff@fotomarket.com','','444-44444',1,'555','','no paper bills',0,0),
 (8,10,'Addd Inc.','asasa@addd.coom','','',1,'555-555-5555','','',0,0);
INSERT INTO "contacts" ("id","addressid","title","name","email","officephone","cellphone","fax","website","notes","createdby","companyid","disabled","cccontact") VALUES (1,3,'Sales','Namo McPherson','namo@ttb.com','705-555-5551','444-666-6666','','','',0,9,0,'3,4,5'),
 (2,5,'CEO','Linda Gerry','linda@waave.net','778-555-9999','444-666-6666','','','',0,1,0,' '),
 (3,1,'Marketing','Jennifer Cox','jcox@boxesboxes.com','775-444-1234','775-555-5552','','','',0,8,0,'  ');
INSERT INTO "contracttype" ("id","title","terms","rate") VALUES (0,'Time and Material','',0),
 (1,'Quote for Service','',0),
 (2,'Gold-Limited All Inclusive','',5000);
INSERT INTO "costs" ("id","name","longname","multiplier","createdby") VALUES (1,'-5%','5% Discount',-0.05,0),
 (2,'-10%','10% Discount',-0.1,0),
 (3,'-15%','15% Discount',-0.15,0),
 (4,'-20%','20% Discount',-0.2,0),
 (5,'-25%','25% Discount',-0.25,0),
 (6,'-30%','30% Discount',-0.3,0),
 (7,'-50%','50% Discount',-0.5,0),
 (8,'-75%','75% Discount',-0.75,0);
INSERT INTO "dispatch" ("id","equipmentid","addressid","contactid","date","reportedissue","status","reportedby","contact","notes","data","hourlyrate","travelrate","contracttype","worktype","createdby","disabled") VALUES (10022,3333,1,7,202308270932,'foooo',3,'','','','',2,3,1,3,0,0),
 (10023,3333,2,7,202308270932,'foooo',3,'','','','',2,3,0,3,0,0),
 (10024,4444,3,2,202308270932,'jhjhjhhkjjhhhj',3,'','','','',1,1,0,1,0,0),
 (10025,4444,4,7,202308270932,'skdk',3,'','','','',2,3,0,1,0,0);
INSERT INTO "equipment" ("id","name","addressid","contactid","typeid","sn","notes","createdby","disabled") VALUES ('F1637','K526 Fridge2',1,2,26,'FFF-4444-FFF','d',0,0),
 ('1853','X33 Plasma Manifold',1,8,7,'32144-343535','located underfloor',0,0),
 ('4444','Torch',6,7,1,'425-63766','',0,0),
 ('5444','Flash Light',7,2,28,'645-3666','',0,0),
 ('3333','Wheel Barrow',6,7,1,'7328-86321156','',0,0),
 ('1965','Power Excavator',5,1,29,'52-6663267','3h maintenance fo every 200h service',0,0),
 ('9999','Backpack1',1,1,31,'5227-875332','',0,0);
INSERT INTO "formfields" ("id","fgrp","fieldname") VALUES (2,2,'System ID'),
 (3,2,'Name'),
 (4,2,'IP Address'),
 (5,2,'Subnet Mask'),
 (6,2,'Gateway'),
 (7,2,'DNS1'),
 (8,2,'DNS2'),
 (9,2,'Clean Heatsink'),
 (10,2,'Scandisk'),
 (11,2,'Defragment'),
 (12,2,'Disk Cleanup'),
 (13,2,'Clear Cache'),
 (14,2,'Wipe Screen'),
 (15,2,'Create Backup'),
 (16,2,'Virus Scan'),
 (17,2,'HDD Hours'),
 (18,2,'Notes'),
 (19,3,'Take Bread slices out'),
 (20,3,'Place 2 slices in the toaster'),
 (21,3,'Pull down the lever'),
 (22,3,'Wait until the toast pops up'),
 (23,3,'Butter toast'),
 (24,3,'Eat toast'),
 (25,2,'Additional Info'),
 (26,4,'All crew onboard'),
 (27,4,'Notified Passengers'),
 (28,4,'Locked doors'),
 (29,4,'Cleared with Tower'),
 (30,4,'Fueled up'),
 (31,4,'Taxi to runway'),
 (32,4,'Breaks on'),
 (33,4,'Engine on'),
 (34,4,'Engine to speed'),
 (35,4,'Brakes off'),
 (36,4,'Pull up throttle'),
 (37,4,'Airborne'),
 (38,4,'Radio Tower'),
 (39,5,'Site Name'),
 (40,5,'Align Actuator Plate'),
 (41,5,'Turn topping heaters off'),
 (42,5,'Turn off Auto Mode'),
 (43,5,'Remove cup holder'),
 (44,5,'Remove hopper cover'),
 (45,5,'Remove agitator'),
 (46,5,'Hold pump and wash'),
 (47,5,'Hold wash and pump'),
 (48,5,'Discard waste'),
 (49,5,'Open syrup valves'),
 (50,5,'Rinse in sink'),
 (51,5,'Rinse hopper'),
 (52,5,'Turn on Wash mode'),
 (53,5,'Pour Sanitizer in'),
 (54,5,'Activate wash mode');
INSERT INTO "formfieldtitle" ("id","name","disabled") VALUES (2,'Computer',0),
 (3,'Make Toast',0),
 (4,'Preflight Check',0),
 (5,'Raylor G503 Shake / Softserver Freezer',0);
INSERT INTO "inventory" ("id","name","shelfid","qty","cost","price","supplierid","supplierpartnumber","plustax","notes","createdby","disabled") VALUES ('b','100W LAMP',1,5,5,0,0,'',1,'BROKE',0,0),
 ('12345678','Part 1',2,13,6,0,0,'',1,'','',0),
 ('12345679','Part 2',3,1,7,0,0,'',1,'','',0),
 ('3333','Part 3',4,3,0,0,0,'',1,'','',0),
 ('44444444','M5 Socket Cap Screw',5,4,4.26,0,0,'',1,'noted',11,0),
 ('55555','555 Timers',5,4,500.5,0,0,'',1,'no',0,0),
 ('20000','LEAD WEIGHT',2,2,0,0,0,'',1,'',9,0),
 ('037000663959','Wash Gel',1,0,0,0,0,'',1,'',0,0);
INSERT INTO "invoice" ("id","qtid","desc","date","notes","createdby","disabled") VALUES (20,22,'','','Based on Quote: Q0000022',0,0),
 (21,23,'','','Based on Quote: Q0000023',0,0),
 (22,0,'Invoice for service','202309101204','Based on Quote: Q0000025',0,0),
 (23,0,'','202309131204','Based on Quote: Q0000025',0,0),
 (24,0,'','202309131218','Based on Quote: Q0000025',0,0),
 (25,0,'','','Based on Quote: Q0000025',0,0),
 (26,0,'','','Based on Quote: Q0000025',0,0),
 (27,25,'','202309131305','Based on Quote: Q0000025',0,0);
INSERT INTO "pdfchunks" ("id","chunk") VALUES (0,'/DeviceRGB cs 0.870588 0.901961 0.937255 scn /DeviceGray CS 0 SCN 1 i q 1 0 0 -1 0 792 cm 35.625 286.74 539.25 14.52 re
f
Q q 1 0 0 -1 0 792 cm 35.6889 331.141 539.422 14.52 re
f
Q BT
/DeviceRGB cs 0 0 0 scn /DeviceRGB CS 0 0 0 SCN 1 j 0.099996 w /FXF1 1 Tf 11.977 0 0 12 0 0 Tm 4.87266 56.0835 TD[(The Generic Repair Company Inc.)]TJ
0 -1.15001 TD[(123 RepairCo Court.)]TJ
0 -1.15001 TD[(Denver CO 80123)]TJ
0 -1.15001 TD[(USA)]TJ
0 -1.15001 TD[(Phone: 303-555-5555              FAX: 303-555-5556)]TJ
0 -1.15001 TD[(Email: repairs@genericrepairs.com)]TJ
0 -1.15001 TD[(Website: www.genericrepairs.com)]TJ
ET
q 1 0 0 1 0 792 cm 189 -252.602 m
189 -280.922 l
S
Q BT
11.977 0 0 12 0 0 Tm 3.36978 43.9068 TD[(REASON FOR CALL:)]TJ
0 -1.06668 TD[(REPORTED BY:)]TJ
ET
q 1 0 0 1 0 792 cm 36 -301.238 m
574.5 -301.5 l
S
Q BT
11.9771 0 0 12 0 0 Tm 3.45326 41.0533 TD[(SYSTEM ID:)]TJ
29.6408 0 TD[(SERIAL NUMBER:)]TJ
11.977 0 0 12 0 0 Tm 3.45328 37.4601 TD[(DATE)]TJ
36.8739 0 TD[(TRAVEL  TIME)]TJ
-37.3113 -35.7601 TD[(Thank you for choosing our company)]TJ
ET
/DeviceRGB CS 0.203922 0.396078 0.643137 SCN 0 j 0.12 w q 1 0 0 1 0 792 cm 36 -759.719 m
576 -759.719 l
S
Q q 1 0 0 1 0 792 cm 348 -81 m
348 -231 l
S
Q /DeviceRGB cs 0.6 0.6 0.6 scn q 1 0 0 -1 0 792 cm 57.602 63.84 m
36 63.84 l
36 18.121 l
79.32 18.121 l
79.32 63.84 l
57.602 63.84 l
f*
Q BT
/DeviceRGB cs 0 0 0 scn 15.3304 0 0 15.36 0 0 Tm 5.87067 48.5548 TD[(GENERIC)]TJ
0.978447 -0.88282 TD[(COMPANY)]TJ
-1.52638 1.76563 TD[(THE)]TJ
/DeviceRGB cs 1 1 1 scn /DeviceGray CS 0 SCN 1 w 39.285 0 0 39.36 0 0 Tm 1 i 1.063 18.6921 TD[(G)]TJ
ET
1 i 35.25 720 540.0 -167.25 re
S
35.25 539.75 540.0 -28.5 re
S
35.25 505 540 -28.5 re
S
35.25 461.468 540.0 -419.153 re
S
BT
/DeviceRGB cs 0 0 0 scn /DeviceRGB CS 0 0 0 SCN 1 j 0.099996 w 11.9771 0 0 12 0 0 Tm 1 i 17.8975 41.0533 TD[(EQUIPMENT:)]TJ
11.977 0 0 12 0 0 Tm 1 i 10.1327 37.4601 TD[(WORK PERFORMED)]TJ
1 i 33.7949 -35.7601 TD[(Page: XX)]TJ
/FXF1 12 Tf 1 0 0 1 0 0 Tm 1 i 508 444 TD[( )]TJ
ET
'),
 (1,'/DeviceRGB cs 0.870588 0.901961 0.937255 scn /DeviceGray CS 0 SCN 1 i q 1 0 0 -1 0 792 cm 306.968 32.8802 m
574.99 32.799 l
574.99 47.319 l
35.3449 46.9194 l
35.8291 32.3961 l
306.968 32.8802 l h
f
Q BT
/DeviceRGB cs 0 0 0 scn /DeviceRGB CS 0 0 0 SCN 1 j 0.099996 w /FXF1 1 Tf 11.977 0 0 12 0 0 Tm 3.45328 62.3215 TD[(DATEddd)]TJ
36.8739 0 TD[(TRAVEL  TIME)]TJ
-37.3113 -60.6215 TD[(Thank you for choosing our company)]TJ
ET
/DeviceRGB CS 0.203922 0.396078 0.643137 SCN 0 j 0.12 w q 1 0 0 1 0 792 cm 36 -759.719 m
576 -759.719 l
S
Q BT
/DeviceRGB CS 0 0 0 SCN 1 j 0.099996 w 11.977 0 0 12 0 0 Tm 1 i 10.1327 62.3215 TD[(WORK PERFORMED)]TJ
1 i 33.7949 -60.6215 TD[(Page: XX)]TJ
/FXF1 12 Tf 1 0 0 1 0 0 Tm 1 i 547 732 TD[( )]TJ
ET
0 j 1 w 1 i 574.483 41.0667 -540.483 719.253 re
S'),
 (2,'BT
/DeviceRGB cs 0 0 0 scn /DeviceRGB CS 0 0 0 SCN 1 j 0.099996 w /FXF1 1 Tf 11.977 0 0 12 0 0 Tm 1 i 43.9276 1.7 TD[(Page: 1)]TJ
ET
/DeviceRGB cs 0.870588 0.901961 0.937255 scn /DeviceGray CS 0 SCN 0 j 1 w 1 i q 1 0 0 -1 0 792 cm 35.3695 226.668 540.189 17.6834 re
f
Q 1 i q 1 0 0 -1 0 792 cm 35.6889 247.141 539.422 14.52 re
f
Q BT
/DeviceRGB cs 0 0 0 scn /DeviceRGB CS 0 0 0 SCN 1 j 0.099996 w 11.977 0 0 12 0 0 Tm 3.0159 1.69994 TD[(Thank you for choosing our company)]TJ
ET
/DeviceRGB CS 0.203922 0.396078 0.643137 SCN 0 j 0.12 w q 1 0 0 1 0 792 cm 36 -759.719 m
576 -759.719 l
S
Q /DeviceRGB cs 0.6 0.6 0.6 scn q 1 0 0 -1 0 792 cm 57.602 63.84 m
36 63.84 l
36 18.121 l
79.32 18.121 l
79.32 63.84 l
57.602 63.84 l
f*
Q BT
/DeviceRGB cs 0 0 0 scn 15.3304 0 0 15.36 0 0 Tm 5.87067 48.5548 TD[(GENERIC)]TJ
0.978447 -0.88282 TD[(COMPANY)]TJ
-1.52638 1.76563 TD[(THE)]TJ
/DeviceRGB cs 1 1 1 scn /DeviceGray CS 0 SCN 1 w 39.285 0 0 39.36 0 0 Tm 1 i 1.063 18.6921 TD[(G)]TJ
ET
1 i 35.3695 720.195 539.653 -131.821 re
S
35.3696 564.26 539.653 -15.5399 re
S
35.3502 544.914 539.09 -501.894 re
S
1 i 448 746.75 127.25 -21 re
S
BT
/DeviceRGB cs 0 0 0 scn /DeviceRGB CS 0 0 0 SCN 1 j 0.099996 w 11.977 0 0 12 0 0 Tm 1 i 3.36978 45.9901 TD[(REASON FOR QUOTE:)]TJ
1 i 27.9285 17.9934 TD[(P: 303-555-5555  F: 303-555-5556)]TJ
-15.655 -3.41249 TD[(USA       www.genericrepairs.com)]TJ
0.00002 3.45 TD[(The Generic Repair Company Inc.)]TJ
0 -1.15003 TD[(123 RepairCo Court.)]TJ
0 -1.15001 TD[(Denver CO 80123)]TJ
15.655 1.11246 TD[(Email: repairs@genericrepairs.com)]TJ
-27.845 -18.3734 TD[(QTY)]TJ
39.2952 0 TD[(PRICE)]TJ
1 i -32.6158 0.000053 TD[(DESCRIPTION)]TJ
/FXF1 12 Tf 1 0 0 1 0 0 Tm 1 i 172 552 TD[(New door quote)]TJ
ET
/DeviceRGB CS 0.203922 0.396078 0.643137 SCN 0 j 0.12 w 1 i q 1 0 0 1 0 792 cm 296.25 -80.25 m
296.25 -193.5 l
S
Q 
BT
/DeviceRGB cs 0 0 0 scn /DeviceRGB CS 0 0 0 SCN 1 j 0.099996 w /FXF1 1 Tf 11.977 0 0 12 0 0 Tm 1 i 3.36978 45.9901 TD[(REASON FOR QUOTE:)]TJ
1 i 27.9285 17.9934 TD[(P: 303-555-5555  F: 303-555-5556)]TJ
-15.655 -3.41249 TD[(USA       www.genericrepairs.com)]TJ
0.00002 3.45 TD[(The Generic Repair Company Inc.)]TJ
0 -1.15003 TD[(123 RepairCo Court.)]TJ
0 -1.15001 TD[(Denver CO 80123)]TJ
15.655 1.11246 TD[(Email: repairs@genericrepairs.com)]TJ
-27.845 -18.3734 TD[(QTY)]TJ
39.2952 0 TD[(PRICE)]TJ
1 i -32.6158 0.00005 TD[(DESCRIPTION)]TJ
/FXF1 12 Tf 1 0 0 1 0 0 Tm 1 i 172 552 TD[(New door quote)]TJ
1 i 336 -6 TD[(  )]TJ
1 i 35 -42 TD[( )]TJ
1 i 0 -96 TD[( )]TJ
1 i 0 -12 TD[( )]TJ
1 i 0 -12 TD[( )]TJ
1 i 0 -12 TD[( )]TJ
1 i 0 -12 TD[( )]TJ
ET'),
 (3,'BT
/DeviceRGB cs 0 0 0 scn /DeviceRGB CS 0 0 0 SCN 1 j 0.099996 w /FXF1 1 Tf 11.977 0 0 12 0 0 Tm 1 i 43.9276 1.7 TD[(Page: XX)]TJ
ET
/DeviceRGB cs 0.870588 0.901961 0.937255 scn /DeviceGray CS 0 SCN 0 j 1 w 1 i q 1 0 0 -1 0 792 cm 35.6889 72.3443 539.422 14.52 re
f
Q BT
/DeviceRGB cs 0 0 0 scn /DeviceRGB CS 0 0 0 SCN 1 j 0.099996 w 11.977 0 0 12 0 0 Tm 3.0159 1.69994 TD[(Thank you for choosing our company)]TJ
ET
/DeviceRGB CS 0.203922 0.396078 0.643137 SCN 0 j 0.12 w q 1 0 0 1 0 792 cm 36 -759.719 m
576 -759.719 l
S
Q /DeviceRGB cs 0.6 0.6 0.6 scn q 1 0 0 -1 0 792 cm 57.602 63.84 m
36 63.84 l
36 18.121 l
79.32 18.121 l
79.32 63.84 l
57.602 63.84 l
f*
Q BT
/DeviceRGB cs 0 0 0 scn 15.3304 0 0 15.36 0 0 Tm 5.87067 48.5548 TD[(GENERIC)]TJ
0.978447 -0.88282 TD[(COMPANY)]TJ
-1.52638 1.76563 TD[(THE)]TJ
/DeviceRGB cs 1 1 1 scn /DeviceGray CS 0 SCN 1 w 39.285 0 0 39.36 0 0 Tm 1 i 1.063 18.6921 TD[(G)]TJ
ET
1 i 34.5 721.5 540 -676.5 re
S
1 i 468 746.75 107.25 -21 re
S
BT
/DeviceRGB cs 0 0 0 scn /DeviceRGB CS 0 0 0 SCN 1 j 0.099996 w /FXF1 1 Tf 11.977 0 0 12 0 0 Tm 1 i 31.2983 63.9835 TD[(P: 303-555-5555  F: 303-555-5556)]TJ
-15.655 -3.41249 TD[(USA       www.genericrepairs.com)]TJ
0.000022 3.45 TD[(The Generic Repair Company Inc.)]TJ
0 -1.15003 TD[(123 RepairCo Court.)]TJ
0 -1.15001 TD[(Denver CO 80123)]TJ
15.655 1.11246 TD[(Email: repairs@genericrepairs.com)]TJ
-27.845 -3.80697 TD[(QTY)]TJ
39.2952 0 TD[(PRICE)]TJ
1 i -32.6158 0.000042 TD[(DESCRIPTION)]TJ
ET'),
 (4,'BT
/DeviceRGB cs 0 0 0 scn /DeviceRGB CS 0 0 0 SCN 1 j 0.099996 w /FXF1 1 Tf 11.977 0 0 12 0 0 Tm 1 i 43.9276 1.7 TD[(Page: XX)]TJ
ET
/DeviceRGB cs 0.870588 0.901961 0.937255 scn /DeviceGray CS 0 SCN 0 j 1 w 1 i q 1 0 0 -1 0 792 cm 35.6889 247.141 539.422 14.52 re
f
Q BT
/DeviceRGB cs 0 0 0 scn /DeviceRGB CS 0 0 0 SCN 1 j 0.099996 w 11.977 0 0 12 0 0 Tm 1 i 42.7485 44.46 TD[(ITEM)]TJ
ET
/DeviceRGB cs 0.870588 0.901961 0.937255 scn /DeviceGray CS 0 SCN 0 j 1 w 1 i q 1 0 0 -1 0 792 cm 35.3695 226.668 540.189 17.6834 re
f
Q BT
/DeviceRGB cs 0 0 0 scn /DeviceRGB CS 0 0 0 SCN 1 j 0.099996 w 11.977 0 0 12 0 0 Tm 1 i 3.0159 1.69994 TD[(Thank you for choosing our company)]TJ
ET
/DeviceRGB CS 0.203922 0.396078 0.643137 SCN 0 j 0.12 w q 1 0 0 1 0 792 cm 36 -759.719 m
576 -759.719 l
S
Q /DeviceRGB cs 0.6 0.6 0.6 scn q 1 0 0 -1 0 792 cm 57.602 63.84 m
36 63.84 l
36 18.121 l
79.32 18.121 l
79.32 63.84 l
57.602 63.84 l
f*
Q BT
/DeviceRGB cs 0 0 0 scn 15.3304 0 0 15.36 0 0 Tm 5.87067 48.5548 TD[(GENERIC)]TJ
0.978447 -0.88282 TD[(COMPANY)]TJ
-1.52638 1.76563 TD[(THE)]TJ
/DeviceRGB cs 1 1 1 scn /DeviceGray CS 0 SCN 1 w 39.285 0 0 39.36 0 0 Tm 1 i 1.063 18.6921 TD[(G)]TJ
ET
1 i 35.3695 720.195 539.653 -131.821 re
S
35.3696 564.26 539.653 -15.5399 re
S
35.3502 544.914 539.09 -501.894 re
S
1 i 448 746.75 127.25 -21 re
S
BT
/DeviceRGB cs 0 0 0 scn /DeviceRGB CS 0 0 0 SCN 1 j 0.099996 w 11.977 0 0 12 0 0 Tm 1 i 3.36978 45.9901 TD[()]TJ
1 i 27.9285 17.9934 TD[(P: 303-555-5555  F: 303-555-5556)]TJ
-15.655 -3.41249 TD[(USA       www.genericrepairs.com)]TJ
0.00002 3.45 TD[(The Generic Repair Company Inc.)]TJ
0 -1.15003 TD[(123 RepairCo Court.)]TJ
0 -1.15001 TD[(Denver CO 80123)]TJ
15.655 1.11246 TD[(Email: repairs@genericrepairs.com)]TJ
ET
/DeviceRGB CS 0.203922 0.396078 0.643137 SCN 0 j 0.12 w 1 i q 1 0 0 1 0 792 cm 296.25 -80.25 m
296.25 -193.5 l
S
Q BT
/DeviceRGB CS 0 0 0 SCN 1 j 0.099996 w 11.977 0 0 12 0 0 Tm 1 i 38.1866 44.46 TD[(QTY)]TJ
1 i -34.8168 0.000057 TD[(DESCRIPTION)]TJ
ET
'),
 (5,'/DeviceRGB cs 0.870588 0.901961 0.937255 scn /DeviceGray CS 0 SCN 1 i q 1 0 0 -1 0 792 cm 35.6889 31.141 539.422 14.52 re
f
Q BT
/DeviceRGB cs 0 0 0 scn /DeviceRGB CS 0 0 0 SCN 1 j 0.099996 w /FXF1 1 Tf 11.977 0 0 12 0 0 Tm 1 i 43.9276 1.7 TD[(Page: XX)]TJ
1 i -1.1791 60.76 TD[(ITEM)]TJ
1 i -39.7326 -60.7601 TD[(Thank you for choosing our company)]TJ
ET
/DeviceRGB CS 0.203922 0.396078 0.643137 SCN 0 j 0.12 w q 1 0 0 1 0 792 cm 36 -759.719 m
576 -759.719 l
S
Q BT
/DeviceRGB CS 0 0 0 SCN 1 j 0.099996 w 11.977 0 0 12 0 0 Tm 1 i 38.1866 62.46 TD[(QTY)]TJ
1 i -34.8168 0.000057 TD[(DESCRIPTION)]TJ
ET
0 j 1 w 1 i 575.483 42.0667 -540.483 719.253 re
S');
INSERT INTO "qtscope" ("id","typeid","qtid") VALUES (45,7,22),
 (46,6,22),
 (47,7,23),
 (48,6,23),
 (49,0,25),
 (51,1,25);
INSERT INTO "quote" ("id","contracttype","quotedesc","contactid","billingaddressid","sitename","siteaddressid","currencyid","costsubtotal","costtotal","subtotal","total","plustax","date","hourlyrate","travelrate","termsid","data","expirydate","startdate","enddate","maintenancedate","supplierid","notes","createdby","status","disabled") VALUES (25,0,'www',7,6,'','',0,0,0,43.55,46.16,1,20230827,'','',0,'',20231125,20230901,20240831,'','','',0,3,0);
INSERT INTO "salestaxes" ("id","country","state","taxname","taxrate") VALUES (1,'US','AL','Sales Tax',0.0922),
 (2,'US','AK','Sales Tax',0.0176),
 (3,'US','AZ','Sales Tax',0.084),
 (4,'US','AR','Sales Tax',0.0951),
 (5,'CA','AB','GST',0.05),
 (6,'CA','BC','PST',0.07),
 (7,'CA','BC','GST',0.05),
 (8,'CA','MB','PST',0.07),
 (9,'CA','MB','GST',0.05),
 (10,'CA','NB','HST',0.15),
 (11,'CA','NL','HST',0.15),
 (12,'CA','NT','GST',0.05),
 (13,'CA','NS','HST',0.15),
 (14,'CA','NU','GST',0.05),
 (15,'CA','ON','HST',0.13),
 (16,'CA','PE','HST',0.15),
 (17,'CA','QC','QST',0.09975),
 (18,'CA','QC','GST',0.05),
 (19,'CA','SK','PST',0.06),
 (20,'CA','YT','GST',0.05),
 (21,'UK','','VAT',0.2);
INSERT INTO "scf" ("id","scformfields","scfcolid","formfieldtitleid","value","scid") VALUES (447,52,19,3,'1a',28),
 (448,52,20,3,'1',28),
 (449,52,21,3,'2',28),
 (450,52,22,3,'3',28),
 (451,52,23,3,'4',28),
 (452,52,24,3,'5',28),
 (453,53,19,3,'6',28),
 (454,53,20,3,'7',28),
 (455,53,21,3,'8',28),
 (456,53,22,3,'9',28),
 (457,53,23,3,'0',28),
 (458,53,24,3,'a',28),
 (459,54,26,4,'b',28),
 (460,54,27,4,'c',28),
 (461,54,28,4,'yes',28),
 (462,54,29,4,'d',28),
 (463,54,30,4,'e',28),
 (464,54,31,4,'f',28),
 (465,54,32,4,'g',28),
 (466,54,33,4,'h',28),
 (467,54,34,4,'i',28),
 (468,54,35,4,'j',28),
 (469,54,36,4,'k',28),
 (470,54,37,4,'l',28),
 (471,54,38,4,'m',28),
 (491,57,26,4,'disp2',9),
 (492,57,27,4,'a4',9),
 (493,57,28,4,'a5',9),
 (494,57,29,4,'a6',9),
 (495,57,30,4,'a7',9),
 (496,57,31,4,'a8',9),
 (497,57,32,4,'a9',9),
 (498,57,33,4,'b1',9),
 (499,57,34,4,'b2',9),
 (500,57,35,4,'b3',9),
 (501,57,36,4,'b4',9),
 (502,57,37,4,'b5',9),
 (503,57,38,4,'b6',9),
 (504,58,26,4,'d',22),
 (505,58,27,4,'b7',22),
 (506,58,28,4,'b8',22),
 (507,58,29,4,'b9',22),
 (508,58,30,4,'',22),
 (509,58,31,4,'',22),
 (510,58,32,4,'',22),
 (511,58,33,4,'',22),
 (512,58,34,4,'',22),
 (513,58,35,4,'',22),
 (514,58,36,4,'',22),
 (515,58,37,4,'',22),
 (516,58,38,4,'',22),
 (517,59,26,4,'s',24),
 (518,59,27,4,'t',24),
 (519,59,28,4,'yyyyrrrrsss',24),
 (520,59,29,4,'',24),
 (521,59,30,4,'',24),
 (522,59,31,4,'',24),
 (523,59,32,4,'',24),
 (524,59,33,4,'',24),
 (525,59,34,4,'',24),
 (526,59,35,4,'',24),
 (527,59,36,4,'',24),
 (528,59,37,4,'',24),
 (529,59,38,4,'',24),
 (530,60,19,3,'',4),
 (531,60,20,3,'d',4),
 (532,60,21,3,'',4),
 (533,60,22,3,'',4),
 (534,60,23,3,'',4),
 (535,60,24,3,'',4),
 (536,61,39,5,'d',30),
 (537,61,40,5,'',30),
 (538,61,41,5,'',30),
 (539,61,42,5,'',30),
 (540,61,43,5,'',30),
 (541,61,44,5,'',30),
 (542,61,45,5,'',30),
 (543,61,46,5,'',30),
 (544,61,47,5,'',30),
 (545,61,48,5,'',30),
 (546,61,49,5,'',30),
 (547,61,50,5,'',30),
 (548,61,51,5,'',30),
 (549,61,52,5,'',30),
 (550,61,53,5,'',30),
 (551,61,54,5,'',30),
 (552,62,19,3,'',32),
 (553,62,20,3,'',32),
 (554,62,21,3,'',32),
 (555,62,22,3,'',32),
 (556,62,23,3,'',32),
 (557,62,24,3,'',32),
 (558,63,26,4,'y',34),
 (559,63,27,4,'YES',34),
 (560,63,28,4,'Y',34),
 (561,63,29,4,'',34),
 (562,63,30,4,'',34),
 (563,63,31,4,'',34),
 (564,63,32,4,'',34),
 (565,63,33,4,'',34),
 (566,63,34,4,'',34),
 (567,63,35,4,'',34),
 (568,63,36,4,'',34),
 (569,63,37,4,'',34),
 (570,63,38,4,'yy',34),
 (571,64,2,2,'',37),
 (572,64,3,2,'',37),
 (573,64,4,2,'',37),
 (574,64,5,2,'',37),
 (575,64,6,2,'',37),
 (576,64,7,2,'',37),
 (577,64,8,2,'',37),
 (578,64,9,2,'',37),
 (579,64,10,2,'',37),
 (580,64,11,2,'',37),
 (581,64,12,2,'',37),
 (582,64,13,2,'',37),
 (583,64,14,2,'',37),
 (584,64,15,2,'',37),
 (585,64,16,2,'',37),
 (586,64,17,2,'',37),
 (587,64,18,2,'',37),
 (588,64,25,2,'',37),
 (589,65,2,2,'1111',30),
 (590,65,3,2,'',30),
 (591,65,4,2,'',30),
 (592,65,5,2,'',30),
 (593,65,6,2,'',30),
 (594,65,7,2,'',30),
 (595,65,8,2,'',30),
 (596,65,9,2,'',30),
 (597,65,10,2,'',30),
 (598,65,11,2,'',30),
 (599,65,12,2,'',30),
 (600,65,13,2,'',30),
 (601,65,14,2,'',30),
 (602,65,15,2,'',30),
 (603,65,16,2,'',30),
 (604,65,17,2,'',30),
 (605,65,18,2,'',30),
 (606,65,25,2,'',30),
 (607,66,19,3,'123',7),
 (608,66,20,3,'456',7),
 (609,66,21,3,'',7),
 (610,66,22,3,'',7),
 (611,66,23,3,'',7),
 (612,66,24,3,'555',7),
 (613,67,26,4,'YES',8),
 (614,67,27,4,'3',8),
 (615,67,28,4,'',8),
 (616,67,29,4,'',8),
 (617,67,30,4,'',8),
 (618,67,31,4,'',8),
 (619,67,32,4,'',8),
 (620,67,33,4,'',8),
 (621,67,34,4,'',8),
 (622,67,35,4,'',8),
 (623,67,36,4,'',8),
 (624,67,37,4,'y',8),
 (625,67,38,4,'YES',8),
 (626,68,39,5,'djdjjkjjkjjjd',9),
 (627,68,40,5,'',9),
 (628,68,41,5,'',9),
 (629,68,42,5,'',9),
 (630,68,43,5,'',9),
 (631,68,44,5,'',9),
 (632,68,45,5,'',9),
 (633,68,46,5,'',9),
 (634,68,47,5,'',9),
 (635,68,48,5,'',9),
 (636,68,49,5,'',9),
 (637,68,50,5,'',9),
 (638,68,51,5,'',9),
 (639,68,52,5,'',9),
 (640,68,53,5,'',9),
 (641,68,54,5,'040404040aaaa',9),
 (648,70,19,3,'',15),
 (649,70,20,3,'',15),
 (650,70,21,3,'',15),
 (651,70,22,3,'',15),
 (652,70,23,3,'',15),
 (653,70,24,3,'',15),
 (654,71,2,2,'22222000000',1),
 (655,71,3,2,'',1),
 (656,71,4,2,'',1),
 (657,71,5,2,'',1),
 (658,71,6,2,'',1),
 (659,71,7,2,'',1),
 (660,71,8,2,'',1),
 (661,71,9,2,'',1),
 (662,71,10,2,'',1),
 (663,71,11,2,'',1),
 (664,71,12,2,'',1),
 (665,71,13,2,'',1),
 (666,71,14,2,'',1),
 (667,71,15,2,'',1),
 (668,71,16,2,'',1),
 (669,71,17,2,'',1),
 (670,71,18,2,'',1),
 (671,71,25,2,'',1),
 (672,72,19,3,'',1),
 (673,72,20,3,'',1),
 (674,72,21,3,'',1),
 (675,72,22,3,'',1),
 (676,72,23,3,'',1),
 (677,72,24,3,'',1);
INSERT INTO "scformfields" ("id","formfieldtitleid","scid") VALUES (52,3,28),
 (53,3,28),
 (54,4,28),
 (57,4,9),
 (58,4,22),
 (59,4,24),
 (60,3,4),
 (61,5,30),
 (62,3,32),
 (63,4,34),
 (64,2,37),
 (65,2,30),
 (66,3,7),
 (67,4,8),
 (68,5,9),
 (70,3,15),
 (71,2,1),
 (72,3,1);
INSERT INTO "scinv" ("id","inventoryid","scid","userid","qty","sn","notes","date","createdby","disabled") VALUES (14,55555,8,0,1,'','','20230318 18:32',0,0),
 (17,55555,9,0,1,'','','20230318 18:32',0,0),
 (22,37000663959,10,0,3,'','','20230318 18:32',0,0),
 (24,55555,14,0,4,'','','20230318 18:51',0,0),
 (25,55555,12,0,5,'','','20230318 18:50',0,0),
 (26,37000663959,8,0,7,'','','20230706 06:50',0,0),
 (27,37000663959,4,0,7,'','','20230318 19:14',0,0),
 (28,37000663959,33,0,8,'','','20230422 09:21',0,0),
 (29,55555,35,0,5,'','','20230318 18:50',0,0),
 (30,37000663959,37,0,4,'','','20230612 05:22',0,0),
 (31,55555,37,0,3,'','','20230612 05:42',0,0),
 (32,3333,36,0,2,'','','20230612 05:43',0,0),
 (33,37000663959,36,0,1,'','','20230612 05:44',0,0),
 (34,37000663959,34,0,1,'','','20230618 11:29',0,0),
 (35,37000663959,7,0,1,'','','20230621 07:06',0,0),
 (36,55555,8,0,1,'','','20230318 18:32',0,0),
 (37,37000663959,9,0,1,'','','20230624 18:30',0,0),
 (38,0,8,0,1,'','','20230706 06:50',0,0),
 (39,'wasa',37,0,1,'','','20230713 12:29',0,0),
 (40,'wasa',43,0,1,'443434','','20230819 08:31',0,0);
INSERT INTO "servicecall" ("id","dispatchid","userid","date","starttime","time","traveltime","solution","data","workcode","status","createdby","disabled") VALUES (50,10022,0,20330353,'01:00',1.2,1.25,'d','',0,3,0,0),
 (51,10022,0,20220321,'01:32',1.1,1.4,'','',0,3,0,0),
 (52,10022,0,20230101,'09:00',4,6,'','',0,3,0,0),
 (53,10024,0,20230101,'09:00',1,1,'','',0,3,0,0),
 (54,10025,0,20230101,'09:00',1,1,'','',0,3,0,0);
INSERT INTO "shelf" ("id","name","barcode") VALUES (0,'Sales',0),
 (1,'Warehouse A1',11111111),
 (2,'Warehouse A2',11111112),
 (3,'Warehouse A3',11111113),
 (4,'Warehouse A4',11111114),
 (5,'Warehouse A5',11111115),
 (6,'A1',''),
 (13,'roberts desk',1564);
INSERT INTO "sql_queries" ("id","name","query","timestamp") VALUES (1,'GET_TABLE_NAMES','SELECT tbl_name FROM sqlite_master WHERE type=''table''','2026-11-08 02:57:37'),
 (2,'GET_USER_MENU','SELECT user.menu,user.menu FROM user WHERE user.id=''{1}'' AND user.menu<>'''' LIMIT 1','2026-11-08 02:57:37'),
 (3,'GET_SYS_MENU','SELECT menuid, menutext, nextid, previd, readquery, writequery FROM sys_menu WHERE menuid=''{1}'' ORDER BY id ASC','2026-11-08 02:57:37'),
 (4,'GET_INVENTORY_ID','SELECT inventory.id FROM inventory WHERE inventory.id=''{1}''','2026-11-08 02:57:37'),
 (5,'UPDATE_USER_INVID','UPDATE user SET invid=(SELECT inventory.id FROM inventory WHERE inventory.id=''{1}'') WHERE user.id=''{2}''','2026-11-08 02:57:37'),
 (6,'UPDATE_INVENTORY_QTY','UPDATE inventory SET qty=qty+(SELECT (CASE user.invmode WHEN ''D'' THEN ''1'' WHEN ''W'' THEN ''-1'' END) AS A FROM user WHERE user.id=''{1}'') WHERE ((SELECT 1 FROM user WHERE user.invmode=''W'' AND user.id=''{1}'') AND inventory.id=''{2}'' AND qty>0) OR ((SELECT 1 FROM user WHERE user.invmode=''D'' AND user.id=''{1}'') AND inventory.id=''{2}'')','2026-11-08 02:57:37'),
 (7,'GET_USER_INVMODE','SELECT user.invmode AS A FROM user WHERE user.id=''{1}''','2026-11-08 02:57:37'),
 (8,'UPDATE_USERINV_DECREMENT','UPDATE OR IGNORE userinv SET qty=qty-1,date=STRFTIME(''%Y%m%d%H:%M'',datetime(''now'',''localtime'')) WHERE userinv.userid=''{1}'' AND userinv.inventoryid=(SELECT user.invid FROM user WHERE user.id=''{1}'' LIMIT 1);DELETE FROM userinv WHERE userinv.qty=''0'' AND userinv.id IN(SELECT userinv.id FROM userinv LEFT JOIN user ON user.invid=userinv.inventoryid WHERE user.id=''{1}'')','2026-11-08 02:57:37'),
 (9,'UPDATE_USERINV_INCREMENT','UPDATE OR IGNORE userinv SET qty=qty+1,date=STRFTIME(''%Y%m%d%H:%M'',datetime(''now'',''localtime'')) WHERE userinv.userid=''{1}'' AND userinv.inventoryid=(SELECT user.invid FROM user WHERE user.id=''{1}'' LIMIT 1);INSERT or IGNORE INTO userinv(inventoryid,userid,qty,date,notes,createdby,disabled) SELECT user.invid,''{1}'',''1'',STRFTIME(''%Y%m%d%H:%M'',datetime(''now'',''localtime'')),'''',''{2}'',''0'' FROM user WHERE user.id=''{1}'' AND NOT EXISTS(SELECT userinv.inventoryid FROM userinv LEFT JOIN user ON user.invid=userinv.inventoryid WHERE userinv.userid=''{1}'' AND userinv.inventoryid=USER.invid)','2026-11-08 02:57:37'),
 (10,'TOGGLE_USER_INVMODE','UPDATE user SET invmode=CASE invmode WHEN ''D'' THEN ''W'' WHEN ''W'' THEN ''D'' END WHERE user.id=''{1}''','2026-11-08 02:57:37'),
 (11,'GET_TABLE_FIRST_ROW','SELECT '''',* FROM {1} LIMIT 1','2026-11-08 02:57:37'),
 (12,'GET_TABLE_CSV_EXPORT','SELECT ({1}) as OUTPUT FROM (SELECT {2} FROM {3})','2026-11-08 02:57:37'),
 (13,'UPDATE_TABLE_ROW','UPDATE OR IGNORE {1} SET {2} WHERE {3}=''{4}''','2026-11-08 02:57:37'),
 (14,'INSERT_TABLE_ROW','INSERT or IGNORE INTO {1}({2}) VALUES({3})','2026-11-08 02:57:37'),
 (15,'CHECK_USER_LOGIN','SELECT user.login,user.password,user.id FROM user WHERE user.login=''{1}'' AND user.password=''{2}''','2026-11-08 02:57:37'),
 (16,'CHECK_TRUSTED_IP','SELECT user.trustedip,user.id FROM user WHERE user.trustedip=''{1}'' LIMIT 1','2026-11-08 02:57:37'),
 (17,'GET_ALL_USER_FULLNAMES','SELECT fullname FROM user','2026-11-08 02:57:37'),
 (18,'UPDATE_USER_DETAILS','UPDATE or IGNORE user SET name=''{1}'',login=''{2}'',fullname=''{3}'',phone=''{4}'',email=''{5}'',privilege=''{6}'',password=''{7}'',trustedip=''{8}'',menu=''{9}'',invbarcode=''{10}'',disabled=''{11}'' WHERE id=''{12}''','2026-11-08 02:57:37'),
 (19,'GET_USER_SEQ','SELECT seq from sqlite_sequence WHERE sqlite_sequence.name=''user'' LIMIT 1','2026-11-08 02:57:37'),
 (20,'INSERT_NEW_USER','INSERT or IGNORE INTO user(name,login,fullname,phone,email,privilege,password,trustedip,menu,invbarcode,createdby,disabled) VALUES(''{1}'',''{2}'',''{3}'',''{4}'',''{5}'',''{6}'',''{7}'',''{8}'',''{9}'',''{10}'',''{11}'',''{12}'')','2026-11-08 02:57:37'),
 (21,'GET_USER_BY_FULLNAME','SELECT '''',id,name,login,fullname,phone,email,privilege,password,trustedip,menu,invbarcode,disabled FROM user WHERE fullname="{1}"','2026-11-08 02:57:37'),
 (22,'SQLITE_DOT_READ','.read ''{1}''','2026-11-08 02:57:37'),
 (23,'GET_PDF_CHUNK','SELECT chunk FROM pdfchunks WHERE id=''{1}'' LIMIT 1','2026-11-08 02:57:37');
INSERT INTO "status" ("id","status") VALUES (1,'Pending'),
 (2,'Dispatched'),
 (3,'Closed'),
 (4,'Invoiced'),
 (5,'Partially Paid'),
 (6,'Paid'),
 (7,'Done');
INSERT INTO "sys_menu" ("id","menuid","menutext","nextid","previd","readquery","writequery") VALUES (1,'','','','','',''),
 (2,'100','Edit Your Service Call','101','100','',''),
 (3,'100','Edit Your Inventory','815b','100','',''),
 (4,'101','SQLMenu','102','100','SELECT DISTINCT servicecall.id,(substr(servicecall.date,1,4)||''-''||substr(servicecall.date,5,2)||''-''||substr(servicecall.date,7,2)||'' '' ||starttime||'' ''||address.address||'' '' ||servicecall.dispatchid||'' '' ||company.name||'' '' ||dispatch.reportedissue||'' '' ||dispatch.reportedby||'' '' ||dispatch.contact||'' '' ||dispatch.notes||'' '' ||user.name||'' '' ||char(10)) AS OUTPUT FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid LEFT JOIN company ON company.id=contacts.companyid WHERE servicecall.userid=''$userid'' AND dispatch.status=''2''',''),
 (5,'102','Dispatch: ','102','101','SELECT DISTINCT (servicecall.dispatchid||'', ID:''||dispatch.equipmentid||'', ''||address.address||'', User:''||user.name) AS OUTPUT FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (6,'102','Date: ','105','101','SELECT DISTINCT substr(servicecall.date,1,4)||''-''||substr(servicecall.date,5,2)||''-''||substr(servicecall.date,7,2) FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (7,'105','SQLMenu','105a','100','WITH RECURSIVE t(x) AS ( SELECT 1 UNION ALL SELECT x+1 FROM t WHERE x<7*6) SELECT strftime(''%Y%m%d'',date(''now'',''start of month'',''-''||strftime(''%w'',date(''now'',''start of month''))||'' day'',''+''||x||'' day'',''-1 day'')) AS A,(CASE strftime(''%w'',date(''now'',''+''||x||'' days'',''-1 day'')) WHEN ''0'' THEN ''Sunday'' WHEN ''1'' THEN ''Monday'' WHEN ''2'' THEN ''Tuesday'' WHEN ''3'' THEN ''Wednesday'' WHEN ''4'' THEN ''Thursday'' WHEN ''5'' THEN ''Friday'' WHEN ''6'' THEN ''Saturday'' END)||'' ''||(CASE strftime(''%m'',date(''now'',''start of month'',''-''||strftime(''%w'',date(''now'',''start of month''))||'' day'',''+''||x||'' day'',''-1 day'')) WHEN ''01'' THEN ''January'' WHEN ''02'' THEN ''February'' WHEN ''03'' THEN ''March'' WHEN ''04'' THEN ''April'' WHEN ''05'' THEN ''May'' WHEN ''06'' THEN ''June'' WHEN ''07'' THEN ''July'' WHEN ''08'' THEN ''August'' WHEN ''09'' THEN ''September'' WHEN ''10'' THEN ''October'' WHEN ''11'' THEN ''November'' WHEN ''12'' THEN ''December'' END)||'' ''||strftime(''%d'',date(''now'',''start of month'',''-''||strftime(''%w'',date(''now'',''start of month''))||'' day'',''+''||x||'' day'',''-1 day'')) AS A FROM t','UPDATE OR IGNORE servicecall SET date=$rowid WHERE servicecall.id=''$prowid'''),
 (8,'105a','1','102','102','',''),
 (9,'102','Arrival: ','106','101','SELECT DISTINCT servicecall.starttime FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (10,'106','Enter Arrival','102','102','','UPDATE OR IGNORE servicecall SET starttime=(SELECT (CASE length(''$typedtext'') WHEN 4 THEN ''0''||''$typedtext'' ELSE ''$typedtext'' END)) WHERE servicecall.id=''$rowid'''),
 (11,'102','Work Hours: ','107','101','SELECT DISTINCT servicecall.time FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (12,'107','Enter Work Hours','102','102','','UPDATE OR IGNORE servicecall SET time=''$typedtext'' WHERE servicecall.id=''$rowid'';'),
 (13,'102','Travel Hours: ','108','101','SELECT DISTINCT servicecall.traveltime FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (14,'108','Enter Travel Hours','102','102','','UPDATE OR IGNORE servicecall SET traveltime=''$typedtext'' WHERE servicecall.id=''$rowid'';UPDATE servicecall SET travelprice=(SELECT dispatch.travelrate*servicecall.traveltime FROM servicecall LEFT JOIN dispatch ON dispatch.id=servicecall.dispatchid WHERE servicecall.id=$rowid) WHERE servicecall.id=$rowid'),
 (15,'102','Solution: ','109','101','SELECT DISTINCT replace(servicecall.solution,char(10),char(13)||char(10)) FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (16,'109','Enter Solution','110','110','','UPDATE OR IGNORE servicecall SET solution=''$typedtext'' WHERE servicecall.id=''$rowid'''),
 (17,'110','ml','110','112','SELECT replace(servicecall.solution,char(10),char(13)||char(10)),servicecall.solution FROM servicecall WHERE servicecall.id=''$rowid''','UPDATE OR IGNORE servicecall SET solution=(SELECT DISTINCT servicecall.solution FROM servicecall WHERE servicecall.id=''$rowid'')||''$typedtext''||char(10) WHERE servicecall.id=''$rowid'''),
 (18,'112','','102','102','','UPDATE OR IGNORE servicecall SET solution=(SELECT DISTINCT trim(servicecall.solution,char(10)) FROM servicecall WHERE servicecall.id=''$rowid'') WHERE servicecall.id=''$rowid'''),
 (19,'102','Add from User Inventory','171','101','',''),
 (20,'102','SQLMenu','103','101','SELECT scinv.id,(inventory.id||'' - ''||inventory.name||'', SN:''||scinv.sn||'', notes:''||scinv.notes||'', Qty:''||scinv.qty) AS A FROM scinv LEFT JOIN inventory ON inventory.id=scinv.inventoryid WHERE scinv.scid=''$rowid'' ORDER BY scinv.id DESC',''),
 (21,'103','Part: ','103','102','SELECT (inventory.id||'' - ''||inventory.name||'', Qty:''||scinv.qty) AS A FROM scinv LEFT JOIN inventory ON inventory.id=scinv.inventoryid WHERE scinv.id=''$rowid'' LIMIT 1',''),
 (22,'103','Modified: ','103','102','SELECT (scinv.date||'', By:''||user.name) AS A FROM scinv LEFT JOIN user ON user.id=scinv.userid WHERE scinv.id=''$rowid'' LIMIT 1',''),
 (23,'103','SN: ','120','102','SELECT (scinv.sn) AS A FROM scinv LEFT JOIN inventory ON inventory.id=scinv.inventoryid WHERE scinv.id=''$rowid'' LIMIT 1',''),
 (24,'103','Notes: ','121','102','SELECT (scinv.notes) AS A FROM scinv LEFT JOIN inventory ON inventory.id=scinv.inventoryid WHERE scinv.id=''$rowid'' LIMIT 1',''),
 (25,'103','Put into Own Inventory','122','102','',''),
 (26,'122','','123','123','','INSERT or IGNORE INTO userinv(inventoryid,userid,qty,date,notes,createdby,disabled) SELECT scinv.inventoryid,''$userid'',''0'',STRFTIME(''%Y%m%d%H%M'',datetime(''now'',''localtime'')),'''',''$userid'',''0'' FROM scinv WHERE scinv.id=''$rowid'' AND NOT EXISTS(SELECT userinv.inventoryid FROM userinv LEFT JOIN scinv ON scinv.inventoryid=userinv.inventoryid WHERE scinv.id=''$rowid'');UPDATE OR IGNORE scinv SET qty=qty-1 WHERE scinv.inventoryid=(SELECT scinv.inventoryid FROM scinv WHERE scinv.id=''$rowid'' LIMIT 1) AND scinv.id=''$rowid'' AND scinv.qty<>0;UPDATE OR IGNORE userinv SET qty=qty+1,date=STRFTIME(''%Y%m%d%H%M'',datetime(''now'',''localtime'')) WHERE userinv.inventoryid=(SELECT scinv.inventoryid FROM scinv WHERE scinv.id=''$rowid'' LIMIT 1);DELETE FROM scinv WHERE scinv.qty=''0'' AND scinv.id=''$rowid'';'),
 (27,'123','1','102','102','',''),
 (28,'120','Enter Part Serial Number: ','103','103','','UPDATE OR IGNORE scinv SET sn=''$typedtext'' WHERE scinv.id=''$rowid'''),
 (29,'121','Enter Part Notes: ','103','103','','UPDATE OR IGNORE scinv SET notes=''$typedtext'' WHERE scinv.id=''$rowid'''),
 (30,'122','','103','103','','UPDATE OR IGNORE scinv SET sn=''$typedtext'' WHERE scinv.id=''$rowid'''),
 (31,'167','Search User: ','168','168','','c'),
 (32,'168','SQLMenu','175','166','SELECT user.id,(''id:''||user.id||'' login:''||login||'' name:''||user.name||'' fullname:''||fullname||'' p:''||phone||'' e:''||user.email||'' ''||privilege) AS OUTPUT FROM user WHERE user.name LIKE ''%$rowid%'' OR login LIKE ''%$rowid%'' OR user.email LIKE ''%$rowid%'' OR phone LIKE ''%$rowid%'' OR fullname LIKE ''%$rowid%'' LIMIT 14',''),
 (33,'175','','166','166','',''),
 (34,'169','','166','166','','UPDATE OR IGNORE user SET invmode=CASE invmode WHEN ''D'' THEN ''W'' WHEN ''W'' THEN ''D'' END WHERE user.id=''$rowid'''),
 (35,'171','','172','172','SELECT ''$rowid'',''$rowid''',''),
 (36,'172','SQLMenu','173','102','SELECT userinv.id,(userinv.inventoryid||'' - ''||inventory.name||'', qty:''||userinv.qty) AS OUTPUT FROM userinv LEFT JOIN inventory ON inventory.id=userinv.inventoryid WHERE userinv.userid=''$userid'' LIMIT 99',''),
 (37,'173','','174','174','','INSERT or IGNORE INTO scinv(inventoryid,scid,userid,qty,date,notes,createdby,disabled) SELECT userinv.inventoryid,''$pprowid'',userinv.userid,''0'',STRFTIME(''%Y%m%d%H%M'',datetime(''now'',''localtime'')),'''',''$userid'',''0'' FROM userinv WHERE userinv.id=''$rowid'' AND NOT EXISTS(SELECT scinv.inventoryid FROM scinv LEFT JOIN userinv ON userinv.inventoryid=scinv.inventoryid WHERE userinv.id=''$rowid'' AND scinv.scid=''$prowid'');UPDATE OR IGNORE userinv SET qty=qty-1 WHERE userinv.inventoryid=(SELECT userinv.inventoryid FROM userinv WHERE userinv.id=''$rowid'' LIMIT 1) AND userinv.id=''$rowid'' AND userinv.qty<>0;UPDATE OR IGNORE scinv SET qty=qty+1,date=STRFTIME(''%Y%m%d%H%M'',datetime(''now'',''localtime'')) WHERE scinv.inventoryid=(SELECT userinv.inventoryid FROM userinv WHERE userinv.id=''$rowid'' LIMIT 1) AND scinv.scid=''$pprowid'';DELETE FROM userinv WHERE userinv.qty=''0'' AND userinv.id=''$rowid'';'),
 (38,'174','2','102','102','',''),
 (39,'152','SQLMenu','153','101','SELECT inventory.id,(''''||inventory.id||'', name:''||inventory.name||'', shelf:''||(shelf.name)||'', qty:''||qty||'', notes:''||notes||'', disabled:''||disabled) AS OUTPUT FROM inventory LEFT JOIN shelf ON shelf.id=inventory.shelfid WHERE disabled=''0'' ORDER BY inventory.id DESC LIMIT 14',''),
 (40,'153a','Enter Barcode: ','153','153','','INSERT OR IGNORE INTO inventory(id,name,shelfid,qty,notes,createdby,disabled) VALUES(''$typedtext'','''',''1'',''1'','''',''$userid'',''0'')'),
 (41,'154','Enter Barcode: ','153','153','SELECT ''$typedtext'',''$typedtext''','UPDATE OR IGNORE inventory SET id=''$typedtext'' WHERE id<>'''' AND inventory.id=''$rowid'' AND NOT EXISTS (SELECT userinv.inventoryid FROM userinv WHERE userinv.inventoryid=''$rowid'')'),
 (42,'155','Enter Item Name: ','153','153','','UPDATE OR IGNORE inventory SET name=''$typedtext'' WHERE name<>'''' AND inventory.id=''$rowid'''),
 (43,'156','SQLMenu','157','153','SELECT shelf.id,shelf.name FROM shelf','UPDATE OR IGNORE inventory SET shelfid=''$rowid'' WHERE inventory.id=''$prowid'''),
 (44,'157','1','153','153','',''),
 (45,'160','Search Item: ','160a','160a','','c'),
 (46,'160a','SQLMenu','153','101','SELECT inventory.id,(inventory.name||'' '') AS OUTPUT FROM inventory WHERE inventory.name LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE inventory SET shelfid=''$rowid'' WHERE inventory.id=''$pprowid'''),
 (47,'157ss','Enter Serial: ','153','153','','UPDATE OR IGNORE inventory SET sn=''$typedtext'' WHERE inventory.id=''$rowid'''),
 (48,'158','Enter Notes: ','153','153','','UPDATE OR IGNORE inventory SET notes=''$typedtext'' WHERE inventory.id=''$rowid'''),
 (49,'159d','','153','153','','UPDATE OR IGNORE inventory SET disabled=CASE disabled WHEN ''1'' THEN ''0'' WHEN ''0'' THEN ''1'' ELSE ''0'' END WHERE inventory.id=''$rowid'''),
 (50,'159','','153','153','','UPDATE OR IGNORE inventory SET disabled=CASE disabled WHEN ''1'' THEN ''0'' WHEN ''0'' THEN ''1'' ELSE ''0'' END WHERE inventory.id=''$rowid'''),
 (51,'160a','Enter Barcode: ','153','153','SELECT inventory.id,inventory.id FROM inventory WHERE inventory.id=''$typedtext'' ORDER BY inventory.id DESC LIMIT 1','INSERT OR IGNORE INTO inventory(id,shelfid,contactid,createdby,disabled) VALUES(''$typedtext'',''1'',''1'',''$userid'',''0'')'),
 (52,'161','Search inventory: ','162','162','','c'),
 (53,'162','SQLMenu','153','101','SELECT inventory.id,(id ||'' ''||(SELECT shelf FROM shelf WHERE inventory.shelfid=shelf.id LIMIT 1)||'' ''||inventory.name||'' ''||sn ||'' '') AS OUTPUT FROM inventory WHERE inventory.id LIKE ''%$rowid%'' OR inventory.name LIKE ''%$rowid%'' OR sn LIKE ''%$rowid%'' LIMIT 14',''),
 (54,'163','UPDATE OR IGNORE Total Quantity: ','153','153','','UPDATE OR IGNORE inventory SET qty=''$typedtext'' WHERE inventory.id=''$rowid'''),
 (55,'164','UPDATE OR IGNORE Cost: ','153','153','','UPDATE OR IGNORE inventory SET cost=''$typedtext'' WHERE inventory.id=''$rowid'''),
 (56,'102','Add Form','140','401','',''),
 (57,'140','SQLMenu','140a','401','SELECT DISTINCT formfieldtitle.id,formfieldtitle.name FROM formfieldtitle WHERE formfieldtitle.disabled=''0''',''),
 (58,'140a','','102','102','SELECT scformfields.scid,scformfields.scid FROM scformfields ORDER BY scformfields.id DESC LIMIT 1','INSERT OR IGNORE INTO scformfields(formfieldtitleid,scid) VALUES(''$rowid'',''$prowid'');INSERT OR IGNORE INTO scf(scformfields,scfcolid,formfieldtitleid,value,scid) SELECT (SELECT scformfields.id FROM scformfields ORDER BY scformfields.id DESC LIMIT 1),formfields.id AS scfcolid,formfields.fgrp AS formfieldtitleid,'''' AS value,''$prowid'' AS scid FROM formfields WHERE formfields.fgrp=''$rowid'''),
 (59,'102','SQLMenu','141','102','SELECT scformfields.id, (formfieldtitle.name) AS OUTPUT FROM scformfields LEFT JOIN formfieldtitle ON formfieldtitle.id=scformfields.formfieldtitleid WHERE scformfields.scid=''$rowid''',''),
 (60,'102','Status Close, now: ','130','101','SELECT status.status FROM servicecall LEFT JOIN status ON status.id=servicecall.status WHERE servicecall.id=''$rowid''',''),
 (61,'130','','131','131','','UPDATE OR IGNORE servicecall SET status=(SELECT status.id FROM status WHERE status.status=''Closed'' LIMIT 1) WHERE servicecall.id=''$rowid'';UPDATE dispatch SET status=(SELECT servicecall.status FROM servicecall WHERE servicecall.dispatchid=(SELECT servicecall.dispatchid FROM servicecall WHERE servicecall.id=$rowid) ORDER BY servicecall.status ASC LIMIT 1) WHERE dispatch.id=(SELECT servicecall.dispatchid FROM servicecall WHERE servicecall.id=$rowid)'),
 (62,'131','screport','135','101','SELECT servicecall.dispatchid,servicecall.dispatchid FROM servicecall WHERE servicecall.id=''$prowid''',''),
 (63,'134','3','135','101','',''),
 (64,'135','2','102','102','',''),
 (65,'134a','closedispatch','102','101','','UPDATE OR IGNORE dispatch SET status=SELECT (CASE count(DISTINCT servicecall.status) WHEN 1 THEN ''3'' ELSE ''2'' END) AS A FROM servicecall WHERE servicecall.dispatchid=''$prowid'''),
 (66,'141','SQLMenu','142','102','SELECT DISTINCT scf.id,(formfields.fieldname||'': ''||scf.value) AS A FROM scf LEFT JOIN formfieldtitle ON formfieldtitle.id=scf.formfieldtitleid AND scf.scformfields=''$rowid'' LEFT JOIN formfields ON scf.scformfields=''$rowid'' AND formfields.id=scf.scfcolid WHERE scf.scid=''$pprowid'' AND scf.scformfields=''$rowid'' AND formfields.fgrp=scf.formfieldtitleid ORDER BY formfields.id ASC LIMIT 99',''),
 (67,'141','Delete Form','145','102','',''),
 (68,'145','','145a','145a','','DELETE FROM scformfields WHERE scformfields.id IN(SELECT scformfields.id FROM scformfields WHERE scformfields.id=''$rowid'' LIMIT 1);DELETE FROM scf WHERE scf.id IN(SELECT DISTINCT scf.id FROM scf LEFT JOIN formfieldtitle ON formfieldtitle.id=scf.formfieldtitleid AND scf.scformfields=''$rowid'' LEFT JOIN formfields ON scf.scformfields=''$rowid'' AND formfields.id=scf.scfcolid WHERE scf.scid=''$prowid'' AND scf.scformfields=''$rowid'' AND formfields.fgrp=scf.formfieldtitleid ORDER BY formfields.id ASC LIMIT 99)'),
 (69,'145a','1','102','102','',''),
 (70,'142','Enter Valued','143','143','','UPDATE OR IGNORE scf SET value=''$typedtext'' WHERE scf.id=''$rowid'''),
 (71,'143','1','141','141','',''),
 (72,'100','Create Dispatch','201','101','',''),
 (73,'201','Find by Dispatch Number','203','100','',''),
 (74,'203','Enter Dispatch Number: ','204','204','','c'),
 (75,'204','SQLMenu','205','201','SELECT DISTINCT equipment.id, (equipment.id||'' ''||equipment.name||'' sn:''||equipment.sn||'' notes:''||equipment.notes||char(10)) AS OUTPUT FROM equipment LEFT JOIN dispatch ON dispatch.equipmentid=equipment.id WHERE dispatch.id=''$rowid''',''),
 (76,'205','Enter Reported Issue:','406','406','SELECT dispatch.id,(dispatch.id||'' ''||equipmentid||'' ''||reportedby||'' ''||reportedissue||'' ''||contact||'' ''||notes) AS OUTPUT  FROM dispatch ORDER BY dispatch.id DESC LIMIT 1','INSERT OR IGNORE INTO dispatch(equipmentid,addressid,contactid,date,contracttype,reportedissue,hourlyrate,travelrate,status,createdby,disabled) VALUES(''$rowid'',(SELECT addressid FROM equipment where equipment.id=''$rowid''),(SELECT contactid FROM equipment where equipment.id=''$rowid''),STRFTIME(''%Y%m%d%H%M'',datetime(''now'',''localtime'')),(SELECT ifnull((SELECT quote.contracttype FROM equipment LEFT JOIN quote,qtscope ON (quote.contactid=equipment.contactid AND quote.startdate<=strftime(''%Y%m%d'',date(''now'')) AND quote.enddate>=strftime(''%Y%m%d'',date(''now'')) AND qtscope.qtid=quote.id AND qtscope.typeid=equipment.typeid) LEFT JOIN type ON equipment.typeid=type.id WHERE equipment.id=''$rowid'' GROUP by quote.contracttype),0)),''$typedtext'',(SELECT type.hourlyrate FROM equipment LEFT JOIN type ON equipment.typeid=type.id WHERE equipment.id=''$rowid''),(SELECT type.travelrate FROM equipment LEFT JOIN type ON equipment.typeid=type.id WHERE equipment.id=''$rowid''),''1'',''$userid'',''0'')'),
 (77,'201','Find by Address','205b','100','',''),
 (78,'205b','Enter Address: ','205c','205c','','c'),
 (79,'205c','SQLMenu','205','201','SELECT DISTINCT equipment.id, (equipment.id||'' ''||address.address||'' ''||address.city||'' ''||address.state||'' ''||address.zip||'' ''||address.country||'' ''||equipment.name||'' sn:''||equipment.sn||'' notes:''||equipment.notes||char(10)) AS OUTPUT FROM equipment LEFT JOIN address ON address.id=equipment.addressid WHERE address.address LIKE ''%$rowid%'' OR address.city LIKE ''%$rowid%'' OR address.state LIKE ''%$rowid%'' OR address.zip LIKE ''%$rowid%'' OR address.state LIKE ''%$rowid%'' OR address.country LIKE ''%$rowid%'' ORDER BY equipment.id DESC LIMIT 14',''),
 (80,'210','Enter Address: ','206','206','',''),
 (81,'206','Dispatch: ','206','201','SELECT DISTINCT (dispatch.id||'', ''||address.address) AS OUTPUT FROM dispatch LEFT JOIN servicecall ON servicecall.dispatchid=dispatch.id LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE dispatch.id=''$rowid'' LIMIT 1',''),
 (82,'206','Equipment ID: ','206','201','SELECT DISTINCT dispatch.equipmentid FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (83,'206','Work Type: ','234','201','SELECT DISTINCT worktype.worktype FROM dispatch LEFT JOIN worktype ON worktype.id=dispatch.worktype WHERE dispatch.id=''$rowid''',''),
 (84,'234','SQLMenu','206','201','SELECT DISTINCT worktype.id, (worktype.worktype) ORDER BY worktype.id ASC LIMIT 20',''),
 (85,'206','Reported Date: ','206','201','SELECT DISTINCT (substr(dispatch.date,1,4)||''-''||substr(dispatch.date,5,2)||''-''||substr(dispatch.date,7,2)||'' ''||substr(dispatch.date,9,2)||'':''||substr(dispatch.date,11,2)) FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (86,'206','Reported Issue: ','207','201','SELECT DISTINCT dispatch.reportedissue FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (87,'206','Reported By: ','207','201','SELECT DISTINCT dispatch.reportedby FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (88,'206','Reported Contact: ','208','201','SELECT DISTINCT dispatch.contact FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (89,'206','Info: ','209','201','SELECT DISTINCT dispatch.notes FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (90,'206','Dispatched User: ','207','201','SELECT group_concat(name) as name FROM (SELECT DISTINCT name from servicecall LEFT JOIN user ON servicecall.userid=user.id WHERE dispatchid=''$rowid'' ORDER BY userid DESC)',''),
 (91,'206','Status: ','207','201','SELECT DISTINCT dispatch.status FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (92,'207','Enter Person who called in: ','206','206','','UPDATE OR IGNORE dispatch SET reportedby=''$typedtext'' WHERE dispatch.id=''$rowid'''),
 (93,'208','Enter Phone: ','206','206','','UPDATE OR IGNORE dispatch SET contact=''$typedtext'' WHERE dispatch.id=''$rowid'''),
 (94,'209','Enter Notes: ','206','206','','UPDATE OR IGNORE dispatch SET notes=''$typedtext'' WHERE dispatch.id=''$rowid'''),
 (95,'201','Find by Contact ','220','100','',''),
 (96,'220','Enter Contact Name: ','221','221','','c'),
 (97,'221','SQLMenu','205','201','SELECT DISTINCT equipment.id, (equipment.id||'' ''||equipment.name||'' ''||contacts.name||'' ''||company.name||'' sn:''||equipment.sn||char(10)) AS OUTPUT FROM equipment LEFT JOIN contacts ON contacts.id=equipment.contactid LEFT JOIN company ON company.id=contacts.companyid WHERE contacts.name LIKE ''%$rowid%'' ORDER BY equipment.id DESC LIMIT 14',''),
 (98,'201','Find by Company ','222','100','',''),
 (99,'222','Enter Company Name: ','223','223','','c'),
 (100,'223','SQLMenu','205','201','SELECT DISTINCT equipment.id, (equipment.id||'' ''||equipment.name||'' ''||contacts.name||'' ''||company.name||'' sn:''||equipment.sn||char(10)) AS OUTPUT FROM equipment LEFT JOIN contacts ON contacts.id=equipment.contactid LEFT JOIN company ON company.id=contacts.companyid WHERE company.name LIKE ''%$rowid%'' ORDER BY equipment.id DESC LIMIT 14',''),
 (101,'201','Find by Reported Issue ','224','100','',''),
 (102,'224','Enter Issue: ','225','225','','c'),
 (103,'225','SQLMenu','205','201','SELECT DISTINCT equipment.id, (equipment.id||'' ''||equipment.name||'' ''||dispatch.reportedissue||'' sn:''||equipment.sn||char(10)) AS OUTPUT FROM equipment LEFT JOIN dispatch ON dispatch.equipmentid=equipment.id WHERE dispatch.reportedissue LIKE ''%$rowid%'' ORDER BY equipment.id DESC LIMIT 14',''),
 (104,'201','Find by Reported By','226','100','',''),
 (105,'226','Enter Reported By: ','227','227','','c'),
 (106,'227','SQLMenu','205','201','SELECT DISTINCT equipment.id, (equipment.id||'' ''||equipment.name||'' ''||dispatch.reportedby||'' sn:''||equipment.sn||char(10)) AS OUTPUT FROM equipment LEFT JOIN dispatch ON dispatch.equipmentid=equipment.id WHERE dispatch.reportedby LIKE ''%$rowid%'' ORDER BY equipment.id DESC LIMIT 14',''),
 (107,'201','Find by User ','228','100','',''),
 (108,'228','Enter Dispatched User Name: ','229','229','','c'),
 (109,'229','SQLMenu','205','201','SELECT DISTINCT equipment.id, (equipment.id||'' ''||equipment.name||'' ''||user.login||'' ''||user.fullname||'' sn:''||equipment.sn||char(10)) AS OUTPUT FROM dispatch LEFT JOIN equipment ON dispatch.equipmentid=equipment.id LEFT JOIN servicecall ON servicecall.dispatchid=dispatch.id LEFT JOIN user ON servicecall.userid=user.id WHERE user.fullname LIKE ''%$rowid%'' OR user.login LIKE ''%$rowid%'' ORDER BY equipment.id DESC LIMIT 14',''),
 (110,'201','Find by Equipment ID','230','100','',''),
 (111,'230','Enter Equipment ID: ','231','231','','c'),
 (112,'231','SQLMenu','205','201','SELECT DISTINCT equipment.id, (equipment.id||'' ''||equipment.name||'' ''||address.address||'' sn:''||equipment.sn||char(10)) AS OUTPUT FROM equipment LEFT JOIN address ON address.id=equipment.addressid WHERE equipment.id LIKE ''%$rowid%'' ORDER BY equipment.id DESC LIMIT 14',''),
 (113,'201','Find by Equipment Name','232','100','',''),
 (114,'232','Enter Equipment Name: ','233','233','','c'),
 (115,'233','SQLMenu','205','201','SELECT DISTINCT equipment.id, (equipment.id||'' ''||equipment.name||'' ''||address.address||'' sn:''||equipment.sn||char(10)) AS OUTPUT FROM equipment LEFT JOIN address ON address.id=equipment.addressid WHERE equipment.name LIKE ''%$rowid%'' ORDER BY equipment.id DESC LIMIT 14',''),
 (116,'100','Edit Users','301','101','',''),
 (117,'301','List Existing Users','302','100','',''),
 (118,'301','Add User','303','100','',''),
 (119,'301','Find User','316','100','',''),
 (120,'302','SQLMenu','304','301','SELECT user.id,(''id:''||user.id||'' login:''||login||'' name:''||user.name||'' fullname:''||fullname||'' p:''||phone||'' e:''||user.email||'' ''||privilege||char(10)) AS OUTPUT FROM user ORDER BY user.id DESC LIMIT 14',''),
 (121,'316','Search User: ','317','317','','c'),
 (122,'317','SQLMenu','304','301','SELECT user.id,(''id:''||user.id||'' login:''||login||'' name:''||user.name||'' fullname:''||fullname||'' p:''||phone||'' e:''||user.email||'' ''||privilege||char(10)) AS OUTPUT FROM user WHERE user.name LIKE ''%$rowid%'' OR login LIKE ''%$rowid%'' OR fullname LIKE ''%$rowid%'' OR user.email LIKE ''%$rowid%'' OR phone LIKE ''%$rowid%'' LIMIT 14',''),
 (123,'303','Enter New User Login:','304','304','SELECT user.id,user.id FROM user ORDER BY user.id DESC LIMIT 1','INSERT OR IGNORE INTO user(login,name,fullname,password,createdby,disabled) VALUES(''$typedtext'',''$typedtext'',''$typedtext'',''$typedtext'',''$userid'',''0'')'),
 (124,'304','Login: ','305','301','SELECT DISTINCT user.login FROM user WHERE user.id=''$rowid''',''),
 (125,'304','Name: ','306','301','SELECT DISTINCT user.name FROM user WHERE user.id=''$rowid''',''),
 (126,'304','Full Name: ','307','301','SELECT DISTINCT user.fullname FROM user WHERE user.id=''$rowid''',''),
 (127,'304','Phone: ','308','301','SELECT DISTINCT user.phone FROM user WHERE user.id=''$rowid''',''),
 (128,'304','Email: ','309','301','SELECT DISTINCT user.email FROM user WHERE user.id=''$rowid''',''),
 (129,'304','Privilege: ','310','301','SELECT DISTINCT user.privilege FROM user WHERE user.id=''$rowid''',''),
 (130,'304','Password: ','311','301','SELECT DISTINCT user.password FROM user WHERE user.id=''$rowid''',''),
 (131,'304','Trusted IP Address: ','312','301','SELECT DISTINCT user.trustedip FROM user WHERE user.id=''$rowid''',''),
 (132,'304','Barcode: ','313','301','SELECT DISTINCT user.invbarcode FROM user WHERE user.id=''$rowid''',''),
 (133,'304','Home Menu: ','314','301','SELECT DISTINCT user.menu FROM user WHERE user.id=''$rowid''',''),
 (134,'304','Disabled: ','315','301','SELECT DISTINCT user.disabled FROM user WHERE user.id=''$rowid''',''),
 (135,'305','Enter login: ','304','304','','UPDATE OR IGNORE user SET login=''$typedtext'' WHERE user.id=''$rowid'''),
 (136,'306','Enter Short Name: ','304','304','','UPDATE OR IGNORE user SET name=''$typedtext'' WHERE user.id=''$rowid'''),
 (137,'307','Enter Full Name: ','304','304','','UPDATE OR IGNORE user SET fullname=''$typedtext'' WHERE user.id=''$rowid'''),
 (138,'308','Enter Phone: ','304','304','','UPDATE OR IGNORE user SET phone=''$typedtext'' WHERE user.id=''$rowid'''),
 (139,'309','Enter Email: ','304','304','','UPDATE OR IGNORE user SET email=''$typedtext'' WHERE user.id=''$rowid'''),
 (140,'310','Enter Privilege: ','304','304','','UPDATE OR IGNORE user SET privilege=''$typedtext'' WHERE user.id=''$rowid'''),
 (141,'311','Enter Password: ','304','304','','UPDATE OR IGNORE user SET password=''$typedtext'' WHERE user.id=''$rowid'''),
 (142,'312','Enter No Login Required IP Address: ','304','304','','UPDATE OR IGNORE user SET trustedip=''$typedtext'' WHERE user.id=''$rowid'''),
 (143,'313','Enter Barcode: ','304','304','','UPDATE OR IGNORE user SET invbarcode=''$typedtext'' WHERE user.id=''$rowid'''),
 (144,'314','Enter Home Menu: ','304','304','','UPDATE OR IGNORE user SET menu=''$typedtext'' WHERE user.id=''$rowid'''),
 (145,'315','','304','304','','UPDATE OR IGNORE user SET disabled=CASE disabled WHEN ''1'' THEN ''0'' WHEN ''0'' THEN ''1'' ELSE ''0'' END WHERE user.id=''$rowid'''),
 (146,'100','Edit Dispatch','401','101','',''),
 (147,'100','Edit Companies','D01','101','',''),
 (148,'100','Edit Customer Contact','501','101','',''),
 (149,'100','Edit Equipment','601','101','',''),
 (150,'100','Edit Address','701','101','',''),
 (151,'100','Edit Sales Taxes','X01','101','',''),
 (152,'100','Edit Work Type','W01','101','',''),
 (153,'401','List Some Prior Entered Dispatches','404','100','',''),
 (154,'401','Add Dispatch','405','100','',''),
 (155,'401','Find Dispatch','413','100','',''),
 (156,'413','Search Dispatch: ','413a','413a','','c'),
 (157,'413a','SQLMenu','406','401','SELECT dispatch.id,(dispatch.id||'' ''||equipmentid||'' ''||reportedby||'' ''||reportedissue||'' ''||contact||'' ''||notes||char(10)) AS OUTPUT FROM dispatch WHERE dispatch.id LIKE ''%$rowid%'' OR equipmentid LIKE ''%$rowid%'' OR reportedissue LIKE ''%$rowid%'' OR reportedby LIKE ''%$rowid%'' OR dispatch.contact LIKE ''%$rowid%'' LIMIT 14',''),
 (158,'404','SQLMenu','406','401','SELECT dispatch.id,(dispatch.id||'' id:''||equipmentid||'' address:''||address.address||'' date:''||date||'' p:''||contact||'' by:''||reportedby||'' dispatched:''||(SELECT ifnull(group_concat(DISTINCT user.name),'''') as name FROM servicecall LEFT JOIN user ON servicecall.userid=user.id WHERE servicecall.dispatchid=dispatch.id AND servicecall.disabled=''0'' ORDER BY name ASC)) AS OUTPUT FROM dispatch  LEFT JOIN address ON dispatch.addressid=address.id ORDER BY dispatch.id DESC LIMIT 14',''),
 (159,'405','Enter Equipment ID: ','405a','405a','','c'),
 (160,'405a','SQLMenu','405b','401','SELECT DISTINCT equipment.id, (equipment.id||'' ''||equipment.name||'' sn:''||equipment.sn||'' notes:''||equipment.notes||char(10)) AS OUTPUT FROM equipment WHERE equipment.id=''$rowid''',''),
 (161,'405b','Enter Reported Issue:','406','406','SELECT dispatch.id,(dispatch.id||'' ''||equipmentid||'' ''||reportedby||'' ''||reportedissue||'' ''||contact||'' ''||notes) AS OUTPUT  FROM dispatch ORDER BY dispatch.id DESC LIMIT 1 ','INSERT OR IGNORE INTO dispatch(equipmentid,addressid,contactid,date,contracttype,reportedissue,hourlyrate,travelrate,status,createdby,disabled) VALUES(''$rowid'',(SELECT addressid FROM equipment where equipment.id=''$rowid''),(SELECT contactid FROM equipment where equipment.id=''$rowid''),STRFTIME(''%Y%m%d%H%M'',datetime(''now'',''localtime'')),(SELECT ifnull((SELECT quote.contracttype FROM equipment LEFT JOIN quote,qtscope ON (quote.contactid=equipment.contactid AND quote.startdate<=strftime(''%Y%m%d'',date(''now'')) AND quote.enddate>=strftime(''%Y%m%d'',date(''now'')) AND qtscope.qtid=quote.id AND qtscope.typeid=equipment.typeid) LEFT JOIN type ON equipment.typeid=type.id WHERE equipment.id=''$rowid'' GROUP by quote.contracttype),0)),''$typedtext'',(SELECT type.hourlyrate FROM equipment LEFT JOIN type ON equipment.typeid=type.id WHERE equipment.id=''$rowid''),(SELECT type.travelrate FROM equipment LEFT JOIN type ON equipment.typeid=type.id WHERE equipment.id=''$rowid''),''1'',''$userid'',''0'')'),
 (162,'406','Dispatch: ','406','401','SELECT DISTINCT (dispatch.id||'', ''||address.address) AS OUTPUT FROM dispatch LEFT JOIN servicecall ON servicecall.dispatchid=dispatch.id LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE dispatch.id=''$rowid'' LIMIT 1',''),
 (163,'406','Equipment ID: ','407','401','SELECT DISTINCT dispatch.equipmentid FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (164,'406','Contract Type: ','430','401','SELECT contracttype.title FROM contracttype LEFT JOIN dispatch ON dispatch.contracttype=contracttype.id WHERE dispatch.id=$rowid',''),
 (165,'430','SQLMenu','431','406','SELECT contracttype.id,(contracttype.title) AS A FROM contracttype','UPDATE OR IGNORE dispatch SET contracttype=''$rowid'' WHERE dispatch.id=''$prowid'''),
 (166,'431','1','406','406','',''),
 (167,'406','Work Type: ','436','401','SELECT worktype.worktype FROM dispatch LEFT JOIN worktype ON worktype.id=dispatch.worktype WHERE dispatch.id=''$rowid''',''),
 (168,'436','SQLMenu','431','401','SELECT worktype.id, (worktype.worktype) FROM worktype ORDER BY worktype.id ASC LIMIT 20','UPDATE OR IGNORE dispatch SET worktype=''$rowid'' WHERE dispatch.id=''$prowid'''),
 (169,'406','Reported Date: ','406','401','SELECT DISTINCT (substr(dispatch.date,1,4)||''-''||substr(dispatch.date,5,2)||''-''||substr(dispatch.date,7,2)||'' ''||substr(dispatch.date,9,2)||'':''||substr(dispatch.date,11,2)) FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (170,'406','Reported Issue: ','409','401','SELECT DISTINCT dispatch.reportedissue FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (171,'406','Reported By: ','410','401','SELECT DISTINCT dispatch.reportedby FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (172,'406','Reported Contact: ','411','401','SELECT DISTINCT dispatch.contact FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (173,'406','Notes: ','412','401','SELECT DISTINCT dispatch.notes FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (174,'406','Add User to Dispatch ','415','401','',''),
 (175,'406','SQLMenu','417','406','SELECT servicecall.id, (user.name ||'' ''||substr(servicecall.date,1,4)||''-''||substr(servicecall.date,5,2)||''-''||substr(servicecall.date,7,2) ||'' ''||servicecall.starttime ||'' h:''||servicecall.time ||'' t:''||servicecall.traveltime) AS OUTPUT FROM servicecall LEFT JOIN user ON user.id=servicecall.userid WHERE dispatchid=''$rowid'' AND servicecall.disabled=''0'' ORDER BY servicecall.date DESC',''),
 (176,'406','Add Self to Dispatch ','417d','401','',''),
 (177,'431','SQLMenu','432','406','SELECT DISTINCT scf.id,(formfields.fieldname||'': ''||scf.value) AS A FROM scf LEFT JOIN formfieldtitle ON formfieldtitle.id=scf.formfieldtitleid AND scf.scformfields=''$rowid'' LEFT JOIN formfields ON scf.scformfields=''$rowid'' AND formfields.id=scf.scfcolid WHERE scf.scid=''$pprowid'' AND scf.scformfields=''$rowid'' AND formfields.fgrp=scf.formfieldtitleid ORDER BY formfields.id ASC LIMIT 99',''),
 (178,'431','Delete Form','435','406','',''),
 (179,'435','','406','406','SELECT ''$prowid'',''$prowid''','DELETE FROM scformfields WHERE scformfields.id IN(SELECT scformfields.id FROM scformfields WHERE scformfields.id=''$rowid'' LIMIT 1);DELETE FROM scf WHERE scf.id IN(SELECT DISTINCT scf.id FROM scf LEFT JOIN formfieldtitle ON formfieldtitle.id=scf.formfieldtitleid AND scf.scformfields=''$rowid'' LEFT JOIN formfields ON scf.scformfields=''$rowid'' AND formfields.id=scf.scfcolid WHERE scf.scid=''$pprowid'' AND scf.scformfields=''$rowid'' AND formfields.fgrp=scf.formfieldtitleid ORDER BY formfields.id ASC LIMIT 99)'),
 (180,'432','Enter Value','433','433','SELECT ''$prowid'',''$prowid''','UPDATE OR IGNORE scf SET value=''$typedtext'' WHERE scf.id=''$rowid'''),
 (181,'433','','434','434','SELECT scf.scid,scf.scid FROM scf WHERE id=''$rowid''',''),
 (182,'434','','431','431','SELECT ''$prowid'',''$prowid''',''),
 (183,'406','Status: ','414','401','SELECT DISTINCT (dispatch.status ||'' ''||status.status) AS OUTPUT FROM dispatch LEFT JOIN status ON status.id=dispatch.status WHERE dispatch.id=''$rowid''',''),
 (184,'455','','456','456','','UPDATE OR IGNORE servicecall SET status=(SELECT status.id FROM status WHERE status.status=''Closed'' LIMIT 1) WHERE servicecall.dispatchid=''$rowid'''),
 (185,'456','screport','457','406','SELECT servicecall.dispatchid,servicecall.dispatchid FROM servicecall WHERE servicecall.id=''$rowid''',''),
 (186,'457','','458','458','SELECT 1,(CASE count(1) WHEN 1 THEN substr(servicecall.date,1,4)||''-''||substr(servicecall.date,5,2)||''-''||substr(servicecall.date,7,2) ELSE ''0'' END) AS A FROM servicecall WHERE servicecall.dispatchid=''$rowid'' AND substr(servicecall.date,1,4)||''-''||substr(servicecall.date,5,2)||''-''||substr(servicecall.date,7,2)=''$prowid'' GROUP BY (servicecall.status) HAVING servicecall.status',''),
 (187,'458','','459','459','','UPDATE OR IGNORE dispatch SET status= (SELECT CASE count(DISTINCT servicecall.status) WHEN 1 THEN ''3'' ELSE ''2'' END  FROM servicecall JOIN dispatch ON dispatch.id=servicecall.dispatchid WHERE servicecall.dispatchid=''$prowid'') WHERE dispatch.id=''$prowid'''),
 (188,'459','3','460','460','',''),
 (189,'460','2','406','406','',''),
 (190,'407d','Enter Equipment: ','406','406','','UPDATE OR IGNORE dispatch SET equipmentid=''$typedtext'' WHERE dispatch.id=''$rowid'''),
 (191,'407','Search Equipment: ','418','418','','c'),
 (192,'418','SQLMenu','419','406','SELECT equipment.id,(equipment.id ||'' ''||(SELECT address FROM address WHERE equipment.addressid=address.id LIMIT 1)||'' ''||equipment.name||'' ''||sn ||'' '') AS OUTPUT FROM equipment WHERE equipment.id LIKE ''%$rowid%'' OR equipment.name LIKE ''%$rowid%'' OR sn LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE dispatch SET equipmentid=''$rowid'' WHERE dispatch.id=''$pprowid'''),
 (193,'419','2','406','406','',''),
 (194,'408','Enter Date: ','406','406','','UPDATE OR IGNORE dispatch SET date=replace(replace(replace(replace((''$typedtext''),''-'',''''),'' '',''''),''.'',''''),'':'','''') WHERE dispatch.id=''$rowid'''),
 (195,'409','Enter Issue: ','406','406','','UPDATE OR IGNORE dispatch SET reportedissue=''$typedtext'' WHERE dispatch.id=''$rowid'''),
 (196,'410','Enter Person who called in: ','406','406','','UPDATE OR IGNORE dispatch SET reportedby=''$typedtext'' WHERE dispatch.id=''$rowid'''),
 (197,'411','Enter Phone: ','406','406','','UPDATE OR IGNORE dispatch SET contact=''$typedtext'' WHERE dispatch.id=''$rowid'''),
 (198,'412','Enter Notes: ','406','406','','UPDATE OR IGNORE dispatch SET notes=''$typedtext'' WHERE dispatch.id=''$rowid'''),
 (199,'415','Enter Dispatched User: ','416','416','','c'),
 (200,'416','SQLMenu','417b','401','SELECT user.id,(''id:''||user.id||'' login:''||login||'' name:''||user.name||'' fullname:''||fullname||'' p:''||phone||'' e:''||user.email||'' ''||privilege) AS OUTPUT FROM user WHERE user.name LIKE ''%$rowid%'' OR login LIKE ''%$rowid%'' OR fullname LIKE ''%$rowid%'' OR user.email LIKE ''%$rowid%'' OR phone LIKE ''%$rowid%'' LIMIT 14',''),
 (201,'417b','Enter Onsite Date:','417c','417c','','INSERT OR IGNORE INTO servicecall(dispatchid,userid,date,createdby,disabled) VALUES(''$pprowid'',''$rowid'',replace(replace(replace(replace((''$typedtext''),''-'',''''),'' '',''''),''.'',''''),'':'',''''),''$userid'',''0'');UPDATE OR IGNORE dispatch SET status=''2'' WHERE dispatch.id=''$pprowid'''),
 (202,'417c','2','406','406','',''),
 (203,'417d','Enter Onsite Date:','406','406','','INSERT OR IGNORE INTO servicecall(dispatchid,userid,date,createdby,disabled) VALUES(''$rowid'',''$userid'',replace(replace(replace(replace((''$typedtext''),''-'',''''),'' '',''''),''.'',''''),'':'',''''),''$userid'',''0'');UPDATE OR IGNORE dispatch SET status=''2'' WHERE dispatch.id=''$rowid'''),
 (204,'f417b','SQLMenu','417','401','SELECT servicecall.id,servicecall.id FROM servicecall ORDER BY servicecall.id DESC LIMIT 1',''),
 (205,'414','Enter Status: ','406','406','','UPDATE OR IGNORE dispatch SET status=''$typedtext'' WHERE dispatch.id=''$rowid'''),
 (206,'417','User: ','423','406','SELECT DISTINCT (user.name ||'' id: ''||servicecall.userid||'' sc: ''||servicecall.id||'' Dispatch: ''||servicecall.dispatchid) AS OUTPUT FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (207,'417','Date: ','424','406','SELECT DISTINCT substr(servicecall.date,1,4)||''-''||substr(servicecall.date,5,2)||''-''||substr(servicecall.date,7,2) FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (208,'417','Arrival: ','425','406','SELECT DISTINCT servicecall.starttime FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (209,'417','Work Hours: ','426','406','SELECT DISTINCT servicecall.time FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (210,'417','Travel Hours: ','427','406','SELECT DISTINCT servicecall.traveltime FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (211,'417','Solution: ','428','406','SELECT DISTINCT replace(servicecall.solution,char(10),char(13)||char(10)) FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (212,'417','Add from User Inventory','450','406','',''),
 (213,'417','SQLMenu','420','101','SELECT scinv.id,(inventory.id||'' - ''||inventory.name||'', SN:''||scinv.sn||'', notes:''||scinv.notes||'', Qty:''||scinv.qty) AS A FROM scinv LEFT JOIN inventory ON inventory.id=scinv.inventoryid WHERE scinv.scid=''$rowid'' ORDER BY scinv.id DESC',''),
 (214,'450','','451','451','SELECT ''$rowid'',''$rowid''',''),
 (215,'451','SQLMenu','452','453','SELECT userinv.id,(userinv.inventoryid||'' - ''||inventory.name||'', qty:''||userinv.qty) AS OUTPUT FROM userinv LEFT JOIN inventory ON inventory.id=userinv.inventoryid WHERE userinv.userid=''$userid'' LIMIT 99',''),
 (216,'452','','453','453','','INSERT or IGNORE INTO scinv(inventoryid,scid,userid,qty,date,notes,createdby,disabled) SELECT userinv.inventoryid,''$prowid'',''$userid'',''0'',STRFTIME(''%Y%m%d%H%M'',datetime(''now'',''localtime'')),'''',''$userid'',''0'' FROM userinv WHERE userinv.id=''$rowid'' AND NOT EXISTS(SELECT scinv.inventoryid FROM scinv LEFT JOIN userinv ON userinv.inventoryid=scinv.inventoryid WHERE userinv.id=''$rowid'' AND scinv.scid=''$prowid'');UPDATE OR IGNORE userinv SET qty=qty-1 WHERE userinv.inventoryid=(SELECT userinv.inventoryid FROM userinv WHERE userinv.id=''$rowid'' LIMIT 1) AND userinv.id=''$rowid'' AND userinv.qty<>0;UPDATE OR IGNORE scinv SET qty=qty+1,date=STRFTIME(''%Y%m%d%H%M'',datetime(''now'',''localtime'')) WHERE scinv.inventoryid=(SELECT userinv.inventoryid FROM userinv WHERE userinv.id=''$rowid'' LIMIT 1) AND scinv.scid=''$prowid'';DELETE FROM userinv WHERE userinv.qty=''0'' AND userinv.id=''$rowid'';'),
 (217,'453','3','417','417','',''),
 (218,'420','Part: ','420','417','SELECT (inventory.id||'' - ''||inventory.name||'', Qty:''||scinv.qty) AS A FROM scinv LEFT JOIN inventory ON inventory.id=scinv.inventoryid WHERE scinv.id=''$rowid'' LIMIT 1',''),
 (219,'420','SN: ','421','417','SELECT (scinv.sn) AS A FROM scinv LEFT JOIN inventory ON inventory.id=scinv.inventoryid WHERE scinv.id=''$rowid'' LIMIT 1',''),
 (220,'420','Notes: ','422','417','SELECT (scinv.notes) AS A FROM scinv LEFT JOIN inventory ON inventory.id=scinv.inventoryid WHERE scinv.id=''$rowid'' LIMIT 1',''),
 (221,'420','Put into Own Inventory','446','417','',''),
 (222,'446','','447','447','','INSERT or IGNORE INTO userinv(inventoryid,userid,qty,date,notes,createdby,disabled) SELECT scinv.inventoryid,''$userid'',''0'',STRFTIME(''%Y%m%d%H%M'',datetime(''now'',''localtime'')),'''',''$userid'',''0'' FROM scinv WHERE scinv.id=''$rowid'' AND NOT EXISTS(SELECT userinv.inventoryid FROM userinv LEFT JOIN scinv ON scinv.inventoryid=userinv.inventoryid WHERE scinv.id=''$rowid'');UPDATE OR IGNORE scinv SET qty=qty-1 WHERE scinv.inventoryid=(SELECT scinv.inventoryid FROM scinv WHERE scinv.id=''$rowid'' LIMIT 1) AND scinv.id=''$rowid'' AND scinv.qty<>0;UPDATE OR IGNORE userinv SET qty=qty+1,date=STRFTIME(''%Y%m%d%H%M'',datetime(''now'',''localtime'')) WHERE userinv.inventoryid=(SELECT scinv.inventoryid FROM scinv WHERE scinv.id=''$rowid'' LIMIT 1);DELETE FROM scinv WHERE scinv.qty=''0'' AND scinv.id=''$rowid'';'),
 (223,'447','1','417','417','',''),
 (224,'421','Enter Part Serial Number','420','420','','UPDATE OR IGNORE scinv SET sn=''$typedtext'' WHERE scinv.id=''$rowid'''),
 (225,'422','Enter Part Notes','420','420','','UPDATE OR IGNORE scinv SET notes=''$typedtext'' WHERE scinv.id=''$rowid'''),
 (226,'423','','420','420','','UPDATE OR IGNORE scinv SET sn=''$typedtext'' WHERE scinv.id=''$rowid'''),
 (227,'417','Add Form','440','401','',''),
 (228,'440','SQLMenu','440a','401','SELECT DISTINCT formfieldtitle.id,formfieldtitle.name FROM formfieldtitle WHERE formfieldtitle.disabled=''0''',''),
 (229,'440a','','417','417','SELECT scformfields.scid,scformfields.scid FROM scformfields ORDER BY scformfields.id DESC LIMIT 1','INSERT OR IGNORE INTO scformfields(formfieldtitleid,scid) VALUES(''$rowid'',''$prowid'');INSERT OR IGNORE INTO scf(scformfields,scfcolid,formfieldtitleid,value,scid) SELECT (SELECT scformfields.id FROM scformfields ORDER BY scformfields.id DESC LIMIT 1),formfields.id AS scfcolid,formfields.fgrp AS formfieldtitleid,'''' AS value,''$prowid'' AS scid FROM formfields WHERE formfields.fgrp=''$rowid'''),
 (230,'417','SQLMenu','441','417','SELECT scformfields.id, (formfieldtitle.name) AS OUTPUT FROM scformfields LEFT JOIN formfieldtitle ON formfieldtitle.id=scformfields.formfieldtitleid WHERE scformfields.scid=''$rowid''',''),
 (231,'441','SQLMenu','442','417','SELECT DISTINCT scf.id,(formfields.fieldname||'': ''||scf.value) AS A FROM scf LEFT JOIN formfieldtitle ON formfieldtitle.id=scf.formfieldtitleid AND scf.scformfields=''$rowid'' LEFT JOIN formfields ON scf.scformfields=''$rowid'' AND formfields.id=scf.scfcolid WHERE scf.scid=''$pprowid'' AND scf.scformfields=''$rowid'' AND formfields.fgrp=scf.formfieldtitleid ORDER BY formfields.id ASC LIMIT 99',''),
 (232,'441','Delete Form','445','417','',''),
 (233,'445','','445a','445a','','DELETE FROM scformfields WHERE scformfields.id IN(SELECT scformfields.id FROM scformfields WHERE scformfields.id=''$rowid'' LIMIT 1);DELETE FROM scf WHERE scf.id IN(SELECT DISTINCT scf.id FROM scf LEFT JOIN formfieldtitle ON formfieldtitle.id=scf.formfieldtitleid AND scf.scformfields=''$rowid'' LEFT JOIN formfields ON scf.scformfields=''$rowid'' AND formfields.id=scf.scfcolid WHERE scf.scid=''$prowid'' AND scf.scformfields=''$rowid'' AND formfields.fgrp=scf.formfieldtitleid ORDER BY formfields.id ASC LIMIT 99)'),
 (234,'445a','1','417','417','',''),
 (235,'442','Enter Valued','443','443','','UPDATE OR IGNORE scf SET value=''$typedtext'' WHERE scf.id=''$rowid'''),
 (236,'443','1','441','441','',''),
 (237,'417','Status Close, now: ','448','406','SELECT status.status FROM servicecall LEFT JOIN status ON status.id=servicecall.status WHERE servicecall.id=''$rowid''',''),
 (238,'448','','417','417','','UPDATE OR IGNORE servicecall SET status=(SELECT status.id FROM status WHERE status.status=''Closed'' LIMIT 1) WHERE servicecall.id=''$rowid'';UPDATE dispatch SET status=(SELECT servicecall.status FROM servicecall WHERE servicecall.dispatchid=(SELECT servicecall.dispatchid FROM servicecall WHERE servicecall.id=$rowid) ORDER BY servicecall.status ASC LIMIT 1) WHERE dispatch.id=(SELECT servicecall.dispatchid FROM servicecall WHERE servicecall.id=$rowid)'),
 (239,'417','Disabledd: ','429','406','SELECT DISTINCT servicecall.disabled FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (240,'423','Enter User','417','417','','UPDATE OR IGNORE servicecall SET userid=''$typedtext'' WHERE servicecall.id=''$rowid'''),
 (241,'424','Enter Date','417','417','','UPDATE OR IGNORE servicecall SET date=replace(replace(replace(replace((''$typedtext''),''-'',''''),'' '',''''),''.'',''''),'':'','''') WHERE servicecall.id=''$rowid'''),
 (242,'425','Enter Arrival','417','417','','UPDATE OR IGNORE servicecall SET starttime=(SELECT (CASE length(''$typedtext'') WHEN 4 THEN ''0''||''$typedtext'' ELSE ''$typedtext'' END)) WHERE servicecall.id=''$rowid'''),
 (243,'426','Enter Work Hours','417','417','','UPDATE OR IGNORE servicecall SET time=''$typedtext'' WHERE servicecall.id=''$rowid'';'),
 (244,'427','Enter Travel Hours','417','417','','UPDATE OR IGNORE servicecall SET traveltime=''$typedtext'' WHERE servicecall.id=''$rowid'';UPDATE servicecall SET travelprice=(SELECT dispatch.travelrate*servicecall.traveltime FROM servicecall LEFT JOIN dispatch ON dispatch.id=servicecall.dispatchid WHERE servicecall.id=$rowid) WHERE servicecall.id=$rowid'),
 (245,'428','Enter Solution','417','417','','UPDATE OR IGNORE servicecall SET solution=''$typedtext'' WHERE servicecall.id=''$rowid'''),
 (246,'429','','417','417','','UPDATE OR IGNORE servicecall SET disabled=CASE disabled WHEN ''1'' THEN ''0'' WHEN ''0'' THEN ''1'' ELSE ''0'' END WHERE servicecall.id=''$rowid'';UPDATE OR IGNORE dispatch SET status=''1'' WHERE dispatch.id in(SELECT servicecall.dispatchid FROM servicecall WHERE servicecall.id=''$rowid'' LIMIT 1) AND NOT EXISTS (SELECT servicecall.userid FROM servicecall WHERE servicecall.dispatchid=dispatch.id AND servicecall.disabled=''0'' LIMIT 1)'),
 (247,'D01','Add Company','D15','100','',''),
 (248,'D01','Find Company','D16','100','',''),
 (249,'D01','SQLMenu','D03','D01','SELECT company.id,(company.name||'', ''||(SELECT address FROM address WHERE company.addressid=address.id LIMIT 1)) AS OUTPUT FROM company ORDER BY company.id DESC LIMIT 14',''),
 (250,'D03','Name: ','D04','D01','SELECT DISTINCT company.name FROM company WHERE company.id=''$rowid''',''),
 (251,'D03','Address: ','D06','D01','SELECT address FROM address LEFT JOIN company ON company.addressid=address.id WHERE company.id=''$rowid'' LIMIT 1',''),
 (252,'D03','Email: ','D08','D01','SELECT DISTINCT company.email FROM company WHERE company.id=''$rowid''',''),
 (253,'D03','Office Phone: ','D09','D01','SELECT DISTINCT company.officephone FROM company WHERE company.id=''$rowid''',''),
 (254,'D03','Cell Phone: ','D10','D01','SELECT DISTINCT company.cellphone FROM company WHERE company.id=''$rowid''',''),
 (255,'D03','Fax: ','D11','D01','SELECT DISTINCT fax FROM company WHERE company.id=''$rowid''',''),
 (256,'D03','Charge Tax: ','D18','D01','SELECT (CASE company.plustax WHEN ''1'' THEN ''YES'' ELSE ''NO'' END) AS A FROM company WHERE company.id=''$rowid'' LIMIT 1',''),
 (257,'D03','Website: ','D12','D01','SELECT DISTINCT website FROM company WHERE company.id=''$rowid''',''),
 (258,'D03','Notes: ','D13','D01','SELECT DISTINCT notes FROM company WHERE company.id=''$rowid''',''),
 (259,'D03','Created by: ','D03','D01','SELECT (user.name||'', ''||''U''||PRINTF(''%01d'',company.createdby)) AS A FROM company LEFT JOIN user on user.id=company.createdby WHERE company.id=''$rowid''',''),
 (260,'D03','Disabled: ','D14','D01','SELECT DISTINCT disabled FROM company WHERE company.id=''$rowid''',''),
 (261,'D03','SQLMenu','603','D01','SELECT equipment.id,(''ID:''||equipment.id||'', N:''||equipment.name||'', ''||(SELECT address.address FROM address WHERE equipment.addressid=address.id LIMIT 1)||'', C:''||contacts.name) AS OUTPUT FROM equipment LEFT JOIN contacts ON contacts.id=equipment.contactid LEFT JOIN company ON company.id=contacts.companyid  WHERE contacts.companyid=''$rowid'' ORDER BY equipment.id DESC LIMIT 99',''),
 (262,'D04','Enter Name: ','D03','D03','','UPDATE OR IGNORE company SET name=''$typedtext'' WHERE company.id=''$rowid'''),
 (263,'D06','Search Address: ','D06a','D06a','','c'),
 (264,'D06a','SQLMenu','D06c','D03','SELECT address.id,(address.address ||'' ''||city ||'' ''||state ||'' ''||zip) AS OUTPUT FROM address WHERE address LIKE ''%$rowid%'' OR city LIKE ''%$rowid%'' OR state LIKE ''%$rowid%'' OR zip LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE company SET addressid=''$rowid'' WHERE company.id=''$pprowid'''),
 (265,'D06b','','D06c','D06c','SELECT ''$prowid'',''$prowid''',''),
 (266,'D06c','2','D03','D03','',''),
 (267,'D08','Enter Email: ','D03','D03','','UPDATE OR IGNORE company SET email=''$typedtext'' WHERE company.id=''$rowid'''),
 (268,'D09','Enter Office Phone: ','D03','D03','','UPDATE OR IGNORE company SET officephone=''$typedtext'' WHERE company.id=''$rowid'''),
 (269,'D10','Enter Cell Phone: ','D03','D03','','UPDATE OR IGNORE company SET cellphone=''$typedtext'' WHERE company.id=''$rowid'''),
 (270,'D11','Enter Fax: ','D03','D03','','UPDATE OR IGNORE company SET fax=''$typedtext'' WHERE company.id=''$rowid'''),
 (271,'D12','Enter Website: ','D03','D03','','UPDATE OR IGNORE company SET website=''$typedtext'' WHERE company.id=''$rowid'''),
 (272,'D13','Enter Notes: ','D03','D03','','UPDATE OR IGNORE company SET notes=''$typedtext'' WHERE company.id=''$rowid'''),
 (273,'D14','','D03','D03','','UPDATE OR IGNORE company SET disabled=CASE disabled WHEN ''1'' THEN ''0'' WHEN ''0'' THEN ''1'' ELSE ''0'' END WHERE company.id=''$rowid'''),
 (274,'D15','Enter Company Name: ','D03','D03','SELECT company.id,company.id FROM company ORDER BY company.id DESC LIMIT 1','INSERT OR IGNORE INTO company(name,addressid,plustax,createdby,disabled) VALUES(''$typedtext'',0,1,''$userid'',0)'),
 (275,'D16','Search Company Name: ','D17','D17','','c'),
 (276,'D17','SQLMenu','D03','D16','SELECT company.id,(company.name ||'' ''||company.email ||'' ''||company.officephone||'' ''||company.cellphone) AS OUTPUT FROM company WHERE company.name LIKE ''%$rowid%'' OR company.email LIKE ''%$rowid%'' OR company.officephone LIKE ''%$rowid%'' OR company.cellphone LIKE ''%$rowid%'' LIMIT 14',''),
 (277,'D18','','D03','D03','','UPDATE OR IGNORE company SET plustax=CASE plustax WHEN ''1'' THEN ''0'' WHEN ''0'' THEN ''1'' ELSE ''0'' END WHERE company.id=''$rowid'''),
 (278,'501','Add Contact','515','100','',''),
 (279,'501','Find Contact','516','100','',''),
 (280,'501','SQLMenu','503','100','SELECT contacts.id,(''ID:''||contacts.id||'', ''||contacts.name||'', ''||(SELECT address FROM address WHERE contacts.addressid=address.id LIMIT 1)||'', ''||company.name||'''') AS OUTPUT FROM contacts LEFT JOIN company ON company.id=contacts.companyid ORDER BY contacts.id DESC LIMIT 14',''),
 (281,'503','Name: ','504','501','SELECT DISTINCT contacts.name FROM contacts WHERE contacts.id=''$rowid''',''),
 (282,'503','Position: ','505','501','SELECT DISTINCT title FROM contacts WHERE contacts.id=''$rowid''',''),
 (283,'503','Address: ','506','501','SELECT address FROM address LEFT JOIN contacts ON contacts.addressid=address.id WHERE contacts.id=''$rowid'' LIMIT 1',''),
 (284,'503','Company: ','507','501','SELECT DISTINCT company.name FROM contacts LEFT JOIN company ON company.id=contacts.companyid WHERE contacts.id=''$rowid''',''),
 (285,'503','Email: ','508','501','SELECT DISTINCT contacts.email FROM contacts WHERE contacts.id=''$rowid''',''),
 (286,'503','Office Phone: ','509','501','SELECT DISTINCT officephone FROM contacts WHERE contacts.id=''$rowid''',''),
 (287,'503','Cell Phone: ','510','501','SELECT DISTINCT cellphone FROM contacts WHERE contacts.id=''$rowid''',''),
 (288,'503','Fax: ','511','501','SELECT DISTINCT fax FROM contacts WHERE contacts.id=''$rowid''',''),
 (289,'503sss','Website: ','512','501','SELECT DISTINCT website FROM contacts WHERE contacts.id=''$rowid''',''),
 (290,'503','Notes: ','513','501','SELECT DISTINCT notes FROM contacts WHERE contacts.id=''$rowid''',''),
 (291,'503','Disabled: ','514','501','SELECT DISTINCT disabled FROM contacts WHERE contacts.id=''$rowid''',''),
 (292,'503','SQLMenu','603','501','SELECT equipment.id,(''ID:''||equipment.id||'', N:''||equipment.name||'', ''||(SELECT address.address FROM address WHERE equipment.addressid=address.id LIMIT 1)||'', C:''||contacts.name) AS OUTPUT FROM equipment LEFT JOIN contacts ON contacts.id=equipment.contactid LEFT JOIN company ON company.id=contacts.companyid  WHERE equipment.contactid=''$rowid'' ORDER BY equipment.id DESC LIMIT 99',''),
 (293,'504','Enter Name: ','503','503','','UPDATE OR IGNORE contacts SET name=''$typedtext'' WHERE contacts.id=''$rowid'''),
 (294,'505','Enter Position: ','503','503','','UPDATE OR IGNORE contacts SET title=''$typedtext'' WHERE contacts.id=''$rowid'''),
 (295,'506','Search Address: ','506a','506a','','c'),
 (296,'506a','SQLMenu','506c','503','SELECT id,(address ||'' ''||city ||'' ''||state ||'' ''||zip) AS OUTPUT FROM address WHERE address LIKE ''%$rowid%'' OR city LIKE ''%$rowid%'' OR state LIKE ''%$rowid%'' OR zip LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE contacts SET addressid=''$rowid'' WHERE contacts.id=''$pprowid'''),
 (297,'506b','','506c','506c','SELECT ''$prowid'',''$prowid''',''),
 (298,'506c','2','503','503','',''),
 (299,'507','Search Company: ','507a','507a','','c'),
 (300,'507a','SQLMenu','507c','503','SELECT company.id,(company.name) AS OUTPUT FROM company WHERE company.name LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE contacts SET companyid=''$rowid'' WHERE contacts.id=''$pprowid'''),
 (301,'507b','','507c','507c','SELECT ''$prowid'',''$prowid''',''),
 (302,'507c','2','503','503','',''),
 (303,'508','Enter Email: ','503','503','','UPDATE OR IGNORE contacts SET email=''$typedtext'' WHERE contacts.id=''$rowid'''),
 (304,'509','Enter Office Phone: ','503','503','','UPDATE OR IGNORE contacts SET officephone=''$typedtext'' WHERE contacts.id=''$rowid'''),
 (305,'510','Enter Cell Phone: ','503','503','','UPDATE OR IGNORE contacts SET cellphone=''$typedtext'' WHERE contacts.id=''$rowid'''),
 (306,'511','Enter Fax: ','503','503','','UPDATE OR IGNORE contacts SET fax=''$typedtext'' WHERE contacts.id=''$rowid'''),
 (307,'512sss','Enter Website: ','503','503','','UPDATE OR IGNORE contacts SET website=''$typedtext'' WHERE contacts.id=''$rowid'''),
 (308,'513','Enter Notes: ','503','503','','UPDATE OR IGNORE contacts SET notes=''$typedtext'' WHERE contacts.id=''$rowid'''),
 (309,'514','','503','503','','UPDATE OR IGNORE contacts SET disabled=CASE disabled WHEN ''1'' THEN ''0'' WHEN ''0'' THEN ''1'' ELSE ''0'' END WHERE contacts.id=''$rowid'''),
 (310,'515','Must Enter Email Address: ','503','503','SELECT contacts.id,contacts.id FROM contacts ORDER BY contacts.id DESC LIMIT 1','INSERT OR IGNORE INTO contacts(email,createdby,disabled) VALUES(''$typedtext'',''$userid'',''0'')'),
 (311,'516','Search Contact: ','517','517','','c'),
 (312,'517','SQLMenu','503','516','SELECT contacts.id,(contacts.name ||'' ''||company.name||'' ''||contacts.email ||'' ''||contacts.officephone||'' ''||contacts.cellphone) AS OUTPUT FROM contacts LEFT JOIN company ON company.id=contacts.companyid WHERE contacts.name LIKE ''%$rowid%'' OR company.name LIKE ''%$rowid%'' OR contacts.email LIKE ''%$rowid%'' OR contacts.officephone LIKE ''%$rowid%'' OR contacts.cellphone LIKE ''%$rowid%'' LIMIT 14',''),
 (313,'601sss','List Some Prior Entered Equipment','602','100','',''),
 (314,'601','Add Equipment','610','100','',''),
 (315,'601','Find Equipment','611','100','',''),
 (316,'601','Edit Equipment Type','613','100','',''),
 (317,'601','SQLMenu','603','601','SELECT equipment.id,(''ID:''||equipment.id||'', N:''||equipment.name||'', ''||(SELECT address FROM address WHERE equipment.addressid=address.id LIMIT 1)||'', C:''||(SELECT contacts.name FROM contacts WHERE equipment.contactid=contacts.id LIMIT 1)) AS OUTPUT FROM equipment ORDER BY equipment.id DESC LIMIT 14',''),
 (318,'603','Add Equipment','610','601','',''),
 (319,'603','ID: ','604','601','SELECT (''''||equipment.id||'' Name: ''||equipment.name) AS A FROM equipment WHERE equipment.id=''$rowid'' LIMIT 1',''),
 (320,'603','Address: ','605','601','SELECT address FROM address LEFT JOIN equipment ON equipment.addressid=address.id WHERE equipment.id=''$rowid'' LIMIT 1',''),
 (321,'603','Contact: ','606','601','SELECT (contacts.name||'', ''||company.name) AS A FROM contacts LEFT JOIN equipment ON equipment.contactid=contacts.id LEFT JOIN company ON company.id=contacts.companyid WHERE equipment.id=''$rowid'' LIMIT 1',''),
 (322,'603','Equipment Type: ','619','601','SELECT type.name FROM equipment LEFT JOIN type ON type.id=equipment.typeid WHERE equipment.id=''$rowid''',''),
 (323,'603','Serial Number: ','607','601','SELECT DISTINCT sn FROM equipment WHERE equipment.id=''$rowid''',''),
 (324,'603','Notes: ','608','601','SELECT DISTINCT notes FROM equipment WHERE equipment.id=''$rowid''',''),
 (325,'603','Disabled: ','609','601','SELECT DISTINCT disabled FROM equipment WHERE equipment.id=''$rowid''',''),
 (326,'604','Enter Name: ','603','603','','UPDATE OR IGNORE equipment SET name=''$typedtext'' WHERE equipment.id=''$rowid'''),
 (327,'605','Search Address: ','605a','605a','','c'),
 (328,'605a','SQLMenu','605b','603','SELECT id,(address ||'' ''||city ||'' ''||state ||'' ''||zip) AS OUTPUT FROM address WHERE address LIKE ''%$rowid%'' OR city LIKE ''%$rowid%'' OR state LIKE ''%$rowid%'' OR zip LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE equipment SET addressid=''$rowid'' WHERE equipment.id=''$pprowid'''),
 (329,'605b','2','603','603','',''),
 (330,'606','Search Contact: ','606a','606a','','c'),
 (331,'606a','SQLMenu','606b','603','SELECT contacts.id,(contacts.name ||'' ''||company.name||'' ''||contacts.email||'' ''||contacts.officephone||'' ''||contacts.cellphone) AS OUTPUT FROM contacts LEFT JOIN company ON company.id=contacts.companyid WHERE contacts.name LIKE ''%$rowid%'' OR company.name LIKE ''%$rowid%'' OR contacts.email LIKE ''%$rowid%'' OR contacts.officephone LIKE ''%$rowid%'' OR contacts.cellphone LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE equipment SET contactid=''$rowid'' WHERE equipment.id=''$pprowid'''),
 (332,'606b','2','603','603','',''),
 (333,'607','Enter Serial: ','603','603','','UPDATE OR IGNORE equipment SET sn=''$typedtext'' WHERE equipment.id=''$rowid'''),
 (334,'608','Enter Notes: ','603','603','','UPDATE OR IGNORE equipment SET notes=''$typedtext'' WHERE equipment.id=''$rowid'''),
 (335,'609','','603','603','','UPDATE OR IGNORE equipment SET disabled=CASE disabled WHEN ''1'' THEN ''0'' WHEN ''0'' THEN ''1'' ELSE ''0'' END WHERE equipment.id=''$rowid'''),
 (336,'610','Enter Equipment ID Number: ','603','603','SELECT equipment.id,equipment.id FROM equipment WHERE equipment.id=''$typedtext'' ORDER BY equipment.id DESC LIMIT 1','INSERT OR IGNORE INTO equipment(id,addressid,contactid,createdby,disabled) VALUES(''$typedtext'',''1'',''1'',''$userid'',''0'')'),
 (337,'611','Search Equipment: ','612','612','','c'),
 (338,'612','SQLMenu','603','601','SELECT equipment.id,(equipment.id ||'' ''||(SELECT address FROM address WHERE equipment.addressid=address.id LIMIT 1)||'' ''||equipment.name||'' ''||sn ||'' '') AS OUTPUT FROM equipment LEFT JOIN contacts ON contacts.id=equipment.contactid LEFT JOIN company ON company.id=contacts.id WHERE equipment.id LIKE ''%$rowid%'' OR equipment.name LIKE ''%$rowid%'' OR equipment.sn LIKE ''%$rowid%'' OR contacts.name LIKE ''%$rowid%''OR company.name LIKE ''%$rowid%''LIMIT 14',''),
 (339,'613','Add Equipment Type','621','601','',''),
 (340,'613','SQLMenu','614','601','SELECT type.id,(type.billingcode ||'': ''||type.name||'' ''||type.hourlyrate||'' ''||type.travelrate) AS OUTPUT FROM type LIMIT 99',''),
 (341,'614','Add Equipment Type','621','601','',''),
 (342,'614','Name: ','615','601','SELECT type.name FROM type WHERE type.id=''$rowid''',''),
 (343,'614','Hourly Rate: ','616','601','SELECT type.hourlyrate FROM type WHERE type.id=''$rowid''',''),
 (344,'614','Travel Rate: ','617','601','SELECT type.travelrate FROM type WHERE type.id=''$rowid''',''),
 (345,'614','Billing Code: ','618','601','SELECT DISTINCT billingcode FROM type WHERE type.id=''$rowid''',''),
 (346,'614','Disabled: ','620','601','SELECT DISTINCT disabled FROM type WHERE type.id=''$rowid''',''),
 (347,'615','Enter Name: ','614','614','','UPDATE OR IGNORE type SET name=''$typedtext'' WHERE type.id=''$rowid'''),
 (348,'616','Enter Hourly Rate: ','614','614','','UPDATE OR IGNORE type SET hourlyrate=''$typedtext'' WHERE type.id=''$rowid'''),
 (349,'617','Enter Travel Rate: ','614','614','','UPDATE OR IGNORE type SET travelrate=''$typedtext'' WHERE type.id=''$rowid'''),
 (350,'618','Enter Short Billing Code: ','614','614','','UPDATE OR IGNORE type SET billingcode=''$typedtext'' WHERE type.id=''$rowid'''),
 (351,'620','','614','614','','UPDATE OR IGNORE type SET disabled=CASE disabled WHEN ''1'' THEN ''0'' WHEN ''0'' THEN ''1'' ELSE ''0'' END WHERE type.id=''$rowid'''),
 (352,'621','Enter type Type Name: ','614','614','SELECT type.id,type.id FROM type WHERE type.name=''$typedtext'' ORDER BY type.id DESC LIMIT 1','INSERT OR IGNORE INTO type(name,hourlyrate,travelrate,createdby,disabled) VALUES(''$typedtext'',''1'',''1'',''$userid'',''0'')'),
 (353,'619','SQLMenu','622','603','SELECT 0,''Leave Blank''','UPDATE OR IGNORE equipment SET typeid='''' WHERE equipment.id=''$prowid'''),
 (354,'619','SQLMenu','622','601','SELECT type.id,(type.billingcode ||'': ''||type.name||'' ''||type.hourlyrate||'' ''||type.travelrate) AS OUTPUT FROM type LIMIT 99','UPDATE OR IGNORE equipment SET typeid=''$rowid'' WHERE equipment.id=''$prowid'''),
 (355,'622','1','603','603','',''),
 (356,'701','Add Address','710','100','',''),
 (357,'701','Find Address','715','100','',''),
 (358,'701','SQLMenu','703','701','SELECT address.id,(''''||address||'', city:''||city||'', state:''||state||'', zip:''||zip||'', country:''||country||'', disabled:''||disabled) AS OUTPUT FROM address ORDER BY address.id DESC LIMIT 14',''),
 (359,'703','Address: ','704','701','SELECT DISTINCT address FROM address WHERE address.id=''$rowid''',''),
 (360,'703','City: ','705','701','SELECT DISTINCT city FROM address WHERE address.id=''$rowid''',''),
 (361,'703','State: ','706','701','SELECT DISTINCT state FROM address WHERE address.id=''$rowid''',''),
 (362,'703','Zip: ','707','701','SELECT DISTINCT zip FROM address WHERE address.id=''$rowid''',''),
 (363,'703','Country: ','708','701','SELECT DISTINCT country FROM address WHERE address.id=''$rowid''',''),
 (364,'703','Disabled: ','709','701','SELECT DISTINCT disabled FROM address WHERE address.id=''$rowid''',''),
 (365,'704','Enter Address: ','703','703','','UPDATE OR IGNORE address SET address=''$typedtext'' WHERE address.id=''$rowid'''),
 (366,'705','Enter City: ','703','703','','UPDATE OR IGNORE address SET city=''$typedtext'' WHERE address.id=''$rowid'''),
 (367,'706','Enter State: ','703','703','','UPDATE OR IGNORE address SET state=(CASE WHEN upper(''$typedtext'')=''N/A'' THEN '''' WHEN length(''$typedtext'')>1 THEN upper(''$typedtext'') ELSE '''' END) WHERE address.id=''$rowid'''),
 (368,'707','Enter Zip: ','703','703','','UPDATE OR IGNORE address SET zip=replace(upper(''$typedtext''),'' '','''') WHERE address.id=''$rowid'''),
 (369,'708','Enter Country Code: ','703','703','','UPDATE OR IGNORE address SET country=upper(''$typedtext'') WHERE address.id=''$rowid'''),
 (370,'709','','703','703','','UPDATE OR IGNORE address SET disabled=CASE disabled WHEN ''1'' THEN ''0'' WHEN ''0'' THEN ''1'' ELSE ''0'' END WHERE address.id=''$rowid'''),
 (371,'710','Enter Address: ','711','711','SELECT address.id,address.id FROM address ORDER BY address.id DESC LIMIT 1','INSERT OR IGNORE INTO address(address,createdby,disabled) VALUES(''$typedtext'',''$userid'',''0'')'),
 (372,'711','Enter City: ','712','712','','UPDATE OR IGNORE address SET city=''$typedtext'' WHERE address.id=''$rowid'''),
 (373,'712','Enter State: ','713','713','','UPDATE OR IGNORE address SET state=(CASE  WHEN upper(''$typedtext'')=''N/A'' THEN '''' WHEN length(''$typedtext'')>1 THEN upper(''$typedtext'') THEN '''' ELSE '''' END) WHERE address.id=''$rowid'''),
 (374,'713','Enter Zip: ','714','714','','UPDATE OR IGNORE address SET zip=replace(upper(''$typedtext''),'' '','''') WHERE address.id=''$rowid'''),
 (375,'714','Enter Country Code: ','702','702','','UPDATE OR IGNORE address SET country=upper(''$typedtext'') WHERE address.id=''$rowid'''),
 (376,'715','Enter Address: ','716','716','','c'),
 (377,'716','SQLMenu','703','702','SELECT address.id,(address ||'' ''||city ||'' ''||state ||'' ''||zip) AS OUTPUT FROM address WHERE address LIKE ''%$rowid%'' OR city LIKE ''%$rowid%'' OR state LIKE ''%$rowid%'' OR zip LIKE ''%$rowid%'' LIMIT 14',''),
 (378,'100','List Pending','904','100','',''),
 (379,'100','List Dispatched','904a','100','',''),
 (380,'100','List Closed','913','100','',''),
 (381,'100','List Invoiced','904c','100','',''),
 (382,'100','List Paid','904d','100','',''),
 (383,'100','Inventory','801','101','',''),
 (384,'801','Scan Inventory','815','100','',''),
 (385,'815','SQLMenu','815a','801','SELECT user.id,(''id:''||user.id||'' login:''||login||'' name:''||user.name||'' fullname:''||fullname||char(10)) AS OUTPUT FROM user ORDER BY user.id DESC LIMIT 22',''),
 (386,'815a','','816','816','','UPDATE OR IGNORE user SET invid='''';UPDATE OR IGNORE user SET invmode=''D'''),
 (387,'815b','','816','816','SELECT user.id,user.id FROM user WHERE user.id=''$userid''','UPDATE OR IGNORE user SET invid='''';UPDATE OR IGNORE user SET invmode=''D'''),
 (388,'816','SELECTed User: ','817','801','SELECT user.name FROM user WHERE user.id=''$rowid''',''),
 (389,'816','Inventory Mode: ','819','801','SELECT (CASE user.invmode WHEN ''D'' THEN ''Deposit'' ELSE ''Withdraw'' END) AS A  FROM user WHERE user.id=''$rowid''',''),
 (390,'816','SELECTed Part: ','820','801','SELECT (user.invid||'': ''||inventory.name)AS A FROM user LEFT JOIN inventory ON inventory.id=user.invid WHERE user.id=''$rowid''',''),
 (391,'816','Item Location: ','816','801','SELECT shelf.name FROM user LEFT JOIN inventory ON inventory.id=user.invid LEFT JOIN shelf ON shelf.id=inventory.shelfid WHERE user.id=''$rowid''',''),
 (392,'816','Item Quantity: ','816','801','SELECT inventory.qty FROM user LEFT JOIN inventory ON inventory.id=user.invid WHERE user.id=''$rowid''',''),
 (393,'816','Deposit ','823','801','',''),
 (394,'823','','816','816','','UPDATE OR IGNORE user SET invmode=''D'' WHERE user.id=''$rowid'';UPDATE OR IGNORE inventory SET qty=qty+1 WHERE inventory.id=(SELECT user.invid FROM user WHERE user.id=''$rowid'' LIMIT 1);UPDATE OR IGNORE userinv SET qty=qty-1,date=STRFTIME(''%Y%m%d%H%M'',datetime(''now'',''localtime'')) WHERE userinv.userid=''$rowid'' AND userinv.inventoryid=(SELECT user.invid FROM user WHERE user.id=''$rowid'' LIMIT 1);DELETE FROM userinv WHERE userinv.qty=''0'' AND userinv.id IN(SELECT userinv.id FROM userinv LEFT JOIN user ON user.invid=userinv.inventoryid WHERE user.id=''$rowid'')'),
 (395,'816','Withdraw ','824','801','',''),
 (396,'824','','816','816','','UPDATE OR IGNORE user SET invmode=''W'' WHERE user.id=''$rowid'';UPDATE OR IGNORE userinv SET qty=qty+1,date=STRFTIME(''%Y%m%d%H%M'',datetime(''now'',''localtime'')) WHERE userinv.userid=''$rowid'' AND userinv.inventoryid<>'''' AND userinv.inventoryid=(SELECT user.invid FROM user LEFT JOIN inventory ON inventory.id=user.invid WHERE user.id=''$rowid'' AND inventory.qty>0 LIMIT 1);INSERT or IGNORE INTO userinv(inventoryid,userid,qty,date,notes,createdby,disabled) SELECT user.invid,''$rowid'',''1'',STRFTIME(''%Y%m%d%H%M'',datetime(''now'',''localtime'')),'''',''$userid'',''0'' FROM user WHERE user.id=''$rowid'' AND user.invid<>'''' AND NOT EXISTS(SELECT userinv.inventoryid FROM userinv LEFT JOIN user ON user.invid=userinv.inventoryid WHERE userinv.userid=''$rowid'' AND userinv.inventoryid=USER.invid);UPDATE OR IGNORE inventory SET qty=qty-1 WHERE inventory.qty>0 AND inventory.id=(SELECT user.invid FROM user WHERE user.id=''$rowid'' LIMIT 1);'),
 (397,'816','SQLMenu','815a','801','SELECT user.id,(user.name||'': ''||inventory.id||'' - ''||inventory.name||'', Qty:''||userinv.qty||'', ''||userinv.date) AS A FROM userinv LEFT JOIN user on userinv.userid=user.id LEFT JOIN inventory ON inventory.id=userinv.inventoryid WHERE inventory.shelfid>0 AND inventory.disabled=0 ORDER BY userinv.id DESC',''),
 (398,'816','bc','816','816','SELECT user.id  AS A FROM user WHERE user.invbarcode=''$typedtext'' UNION SELECT ''$prowid'' LIMIT 2',''),
 (399,'817','Search User: ','818','818','','c'),
 (400,'818','SQLMenu','825','816','SELECT user.id,(''id:''||user.id||'' login:''||login||'' name:''||user.name||'' fullname:''||fullname||'' p:''||phone||'' e:''||user.email||'' ''||privilege) AS OUTPUT FROM user WHERE user.name LIKE ''%$rowid%'' OR login LIKE ''%$rowid%'' OR user.email LIKE ''%$rowid%'' OR phone LIKE ''%$rowid%'' OR fullname LIKE ''%$rowid%'' LIMIT 14',''),
 (401,'825','','816','816','',''),
 (402,'819','','816','816','','UPDATE OR IGNORE user SET invmode=CASE invmode WHEN ''D'' THEN ''W'' WHEN ''W'' THEN ''D'' END WHERE user.id=''$rowid'''),
 (403,'820','Search Part: ','821','821','','c'),
 (404,'821','SQLMenu','822','816','SELECT inventory.id,(inventory.id||'' ''||inventory.name||'' ''||qty) AS OUTPUT FROM inventory WHERE inventory.id LIKE ''%$rowid%'' OR inventory.name LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE user SET invid=''$rowid'' WHERE user.id=''$pprowid'''),
 (405,'822','2','816','816','',''),
 (406,'801','Add to Inventory','803a','100','',''),
 (407,'801','Find Inventory','810','100','',''),
 (408,'801','SQLMenu','803','801','SELECT inventory.id,(''''||inventory.id||'', name:''||inventory.name||'', shelf:''||(shelf.name)||'', qty:''||qty) AS OUTPUT FROM inventory LEFT JOIN shelf ON shelf.id=inventory.shelfid WHERE inventory.shelfid>0 AND inventory.disabled=0 ORDER BY inventory.id DESC LIMIT 14',''),
 (409,'803a','Enter Barcode >(10000000): ','803','803','SELECT ''$typedtext'',''$typedtext''','INSERT OR IGNORE INTO inventory(id,name,shelfid,qty,notes,createdby,disabled) VALUES(''$typedtext'','''',''1'',''1'','''',''$userid'',''0'')'),
 (410,'803','Barcode: ','804','801','SELECT DISTINCT inventory.id FROM inventory WHERE inventory.id=''$rowid''',''),
 (411,'803','Name: ','805','801','SELECT DISTINCT inventory.name FROM inventory WHERE inventory.id=''$rowid''',''),
 (412,'803','Shelf: ','806','801','SELECT shelf.name FROM shelf LEFT JOIN inventory ON inventory.shelfid=shelf.id WHERE inventory.id=''$rowid'' LIMIT 1',''),
 (413,'803','Qty: ','813','801','SELECT inventory.qty FROM inventory WHERE inventory.id=''$rowid'' LIMIT 1',''),
 (414,'803','Cost: ','814','801','SELECT DISTINCT (''$''||printf(''%.2f'',inventory.cost)) AS A FROM inventory WHERE inventory.id=''$rowid''',''),
 (415,'803','Supplier: ','826','801','SELECT DISTINCT (char(13)||char(10)||''    ''||company.name||char(13)||char(10)||''    ''||address.address||char(13)||char(10)||''    ''||company.officephone||char(13)||char(10)||''    ''||company.email) AS A FROM inventory LEFT JOIN company ON company.id=inventory.supplierid LEFT JOIN address ON address.id=company.id WHERE inventory.id=''$rowid''',''),
 (416,'803','Supplier Part Number: ','829','801','SELECT DISTINCT inventory.supplierpartnumber FROM inventory WHERE inventory.id=''$rowid''',''),
 (417,'803','Price: ','830','801','SELECT DISTINCT (''$''||printf(''%.2f'',inventory.price)) AS A FROM inventory WHERE inventory.id=''$rowid''',''),
 (418,'803','Charge Tax: ','831','801','SELECT (CASE inventory.plustax WHEN ''1'' THEN ''YES'' ELSE ''NO'' END) AS A FROM inventory WHERE inventory.id=''$rowid'' LIMIT 1',''),
 (419,'803','Notes: ','808','801','SELECT DISTINCT inventory.notes FROM inventory WHERE inventory.id=''$rowid''',''),
 (420,'803','Created by: ','803','801','SELECT (user.name||'', ''||''U''||PRINTF(''%01d'',inventory.createdby)) AS A FROM inventory LEFT JOIN user on user.id=inventory.createdby WHERE inventory.id=''$rowid''',''),
 (421,'803','Disabled: ','809','801','SELECT DISTINCT disabled FROM inventory WHERE inventory.id=''$rowid''',''),
 (422,'804','Enter Barcode: ','803','803','SELECT ''$typedtext'',''$typedtext''','UPDATE OR IGNORE inventory SET id=''$typedtext'' WHERE id<>'''' AND inventory.id=''$rowid'' AND NOT EXISTS (SELECT userinv.inventoryid FROM userinv WHERE userinv.inventoryid=''$rowid'')'),
 (423,'805','Enter Item Name: ','803','803','','UPDATE OR IGNORE inventory SET name=''$typedtext'' WHERE inventory.id=''$rowid'''),
 (424,'806','Add New Shelf','806b','803','',''),
 (425,'806b','Enter Shelf Name: ','806','806','SELECT ''$typedtext'',''$typedtext''','INSERT OR IGNORE INTO shelf(name,barcode) VALUES(''$typedtext'',abs(random() % 9000))'),
 (426,'806','SQLMenu','807','803','SELECT shelf.id,shelf.name FROM shelf','UPDATE OR IGNORE inventory SET shelfid=''$rowid'' WHERE inventory.id=''$prowid'''),
 (427,'807','1','803','803','',''),
 (428,'826','Search Company Name: ','827','827','','c'),
 (429,'827','SQLMenu','828','826','SELECT company.id,(company.name ||'' ''||company.email ||'' ''||company.officephone||'' ''||company.cellphone) AS OUTPUT FROM company WHERE company.name LIKE ''%$rowid%'' OR company.email LIKE ''%$rowid%'' OR company.officephone LIKE ''%$rowid%'' OR company.cellphone LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE inventory SET supplierid=''$rowid'' WHERE inventory.id=''$pprowid'''),
 (430,'828','2','803','803','',''),
 (431,'829','Enter Supplier Part Number: ','803','803','','UPDATE OR IGNORE inventory SET supplierpartnumber=''$typedtext'' WHERE inventory.id=''$rowid'''),
 (432,'830','Enter Price: ','803','803','','UPDATE OR IGNORE inventory SET price=''$typedtext'' WHERE inventory.id=''$rowid'''),
 (433,'831','','803','803','','UPDATE OR IGNORE inventory SET plustax=CASE plustax WHEN ''1'' THEN ''0'' WHEN ''0'' THEN ''1'' ELSE ''0'' END WHERE inventory.id=''$rowid'''),
 (434,'810','Search Item: ','810a','810a','','c'),
 (435,'810a','SQLMenu','803','801','SELECT inventory.id,(inventory.name||'' '') AS OUTPUT FROM inventory WHERE inventory.id LIKE ''%$rowid%'' OR inventory.name LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE inventory SET shelfid=''$rowid'' WHERE inventory.id=''$pprowid'''),
 (436,'806ss','Search Contact: ','806a','806a','','c'),
 (437,'806a','SQLMenu','803','801','SELECT contacts.id,(contacts.name ||'' ''||company.name||'' ''||user.email||'' ''||contacts.officephone||'' ''||contacts.cellphone) AS OUTPUT FROM contacts LEFT JOIN company ON company.id=contacts.companyid WHERE contacts.name LIKE ''%$rowid%'' OR company.name LIKE ''%$rowid%'' OR user.email LIKE ''%$rowid%'' OR contacts.officephone LIKE ''%$rowid%'' OR contacts.cell LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE inventory SET contactid=''$rowid'' WHERE inventory.id=''$pprowid'''),
 (438,'807ss','Enter Serial: ','803','803','','UPDATE OR IGNORE inventory SET sn=''$typedtext'' WHERE inventory.id=''$rowid'''),
 (439,'808','Enter Notes: ','803','803','','UPDATE OR IGNORE inventory SET notes=''$typedtext'' WHERE inventory.id=''$rowid'''),
 (440,'809d','','803','803','','UPDATE OR IGNORE inventory SET disabled=CASE disabled WHEN ''1'' THEN ''0'' WHEN ''0'' THEN ''1'' ELSE ''0'' END WHERE  inventory.id=''$rowid'''),
 (441,'809','','803','803','','UPDATE OR IGNORE inventory SET disabled=CASE disabled WHEN ''1'' THEN ''0'' WHEN ''0'' THEN ''1'' ELSE ''0'' END WHERE inventory.id=''$rowid'''),
 (442,'811','Search inventory: ','812','812','','c'),
 (443,'812','SQLMenu','803','801','SELECT inventory.id,(inventory.id ||'' ''||(SELECT shelf FROM shelf WHERE inventory.shelfid=shelf.id LIMIT 1)||'' ''||inventory.name||'' ''||sn ||'' '') AS OUTPUT FROM inventory WHERE inventory.id LIKE ''%$rowid%'' OR inventory.name LIKE ''%$rowid%'' OR sn LIKE ''%$rowid%'' LIMIT 14',''),
 (444,'813','UPDATE OR IGNORE Total Quantity: ','803','803','','UPDATE OR IGNORE inventory SET qty=''$typedtext'' WHERE inventory.id=''$rowid'''),
 (445,'814','UPDATE OR IGNORE Cost: ','803','803','','UPDATE OR IGNORE inventory SET cost=''$typedtext'' WHERE inventory.id=''$rowid'''),
 (446,'904','SQLMenu','906','100','SELECT dispatch.id,(dispatch.id||'' id:''||equipmentid||'' address:''||address.address||'' date:''||date||'' p:''||contact||'' by:''||reportedby||'' dispatched:''||(SELECT ifnull(group_concat(DISTINCT user.name),'''') as name FROM servicecall LEFT JOIN user ON servicecall.userid=user.id WHERE servicecall.dispatchid=dispatch.id AND servicecall.disabled=''0'' ORDER BY name ASC)) AS OUTPUT FROM dispatch LEFT JOIN address ON dispatch.addressid=address.id WHERE dispatch.status=''1'' ORDER BY dispatch.id DESC LIMIT 55',''),
 (447,'904a','SQLMenu','906','100','SELECT dispatch.id,(dispatch.id||'' id:''||equipmentid||'' address:''||address.address||'' date:''||date||'' p:''||contact||'' by:''||reportedby||'' dispatched:''||(SELECT ifnull(group_concat(DISTINCT user.name),'''') as name FROM servicecall LEFT JOIN user ON servicecall.userid=user.id WHERE servicecall.dispatchid=dispatch.id AND servicecall.disabled=''0'' ORDER BY name ASC)) AS OUTPUT FROM dispatch LEFT JOIN address ON dispatch.addressid=address.id WHERE dispatch.status=''2'' ORDER BY dispatch.id DESC LIMIT 55',''),
 (448,'904b','SQLMenu','906','100','SELECT dispatch.id,(dispatch.id||'' id:''||equipmentid||'' address:''||address.address||'' date:''||date||'' p:''||contact||'' by:''||reportedby||'' dispatched:''||(SELECT ifnull(group_concat(DISTINCT user.name),'''') as name FROM servicecall LEFT JOIN user ON servicecall.userid=user.id WHERE servicecall.dispatchid=dispatch.id AND servicecall.disabled=''0'' ORDER BY name ASC)) AS OUTPUT FROM dispatch LEFT JOIN address ON dispatch.addressid=address.id WHERE dispatch.status=''3'' ORDER BY dispatch.id DESC LIMIT 14',''),
 (449,'904c','SQLMenu','906','100','SELECT dispatch.id,(dispatch.id||'' id:''||equipmentid||'' address:''||address.address||'' date:''||date||'' p:''||contact||'' by:''||reportedby||'' dispatched:''||(SELECT ifnull(group_concat(DISTINCT user.name),'''') as name FROM servicecall LEFT JOIN user ON servicecall.userid=user.id WHERE servicecall.dispatchid=dispatch.id AND servicecall.disabled=''0'' ORDER BY name ASC)) AS OUTPUT FROM dispatch LEFT JOIN address ON dispatch.addressid=address.id WHERE dispatch.status=''4'' ORDER BY dispatch.id DESC LIMIT 14',''),
 (450,'904d','SQLMenu','906','100','SELECT dispatch.id,(dispatch.id||'' id:''||equipmentid||'' address:''||address.address||'' date:''||date||'' p:''||contact||'' by:''||reportedby||'' dispatched:''||(SELECT ifnull(group_concat(DISTINCT user.name),'''') as name FROM servicecall LEFT JOIN user ON servicecall.userid=user.id WHERE servicecall.dispatchid=dispatch.id AND servicecall.disabled=''0'' ORDER BY name ASC)) AS OUTPUT FROM dispatch LEFT JOIN address ON dispatch.addressid=address.id WHERE dispatch.status=''5'' ORDER BY dispatch.id DESC LIMIT 14',''),
 (451,'905','Enter Equipment ID: ','905a','905a','','c'),
 (452,'905a','SQLMenu','905b','100','SELECT DISTINCT equipment.id, (equipment.id||'' ''||equipment.name||'' sn:''||equipment.sn||'' notes:''||equipment.notes) AS OUTPUT FROM equipment WHERE equipment.id=''$rowid''',''),
 (453,'905b','Enter Reported Issue:','906','906','SELECT dispatch.id,(dispatch.id||'' ''||equipmentid||'' ''||reportedby||'' ''||reportedissue||'' ''||contact||'' ''||notes) AS OUTPUT  FROM dispatch ORDER BY dispatch.id DESC LIMIT 1 ','INSERT OR IGNORE INTO dispatch(equipmentid,addressid,contactid,date,contracttype,reportedissue,hourlyrate,travelrate,status,createdby,disabled) VALUES(''$rowid'',(SELECT addressid FROM equipment where equipment.id=''$rowid''),(SELECT contactid FROM equipment where equipment.id=''$rowid''),STRFTIME(''%Y%m%d%H%M'',datetime(''now'',''localtime'')),(SELECT ifnull((SELECT quote.contracttype FROM equipment LEFT JOIN quote,qtscope ON (quote.contactid=equipment.contactid AND quote.startdate<=strftime(''%Y%m%d'',date(''now'')) AND quote.enddate>=strftime(''%Y%m%d'',date(''now'')) AND qtscope.qtid=quote.id AND qtscope.typeid=equipment.typeid) LEFT JOIN type ON equipment.typeid=type.id WHERE equipment.id=''$rowid'' GROUP by quote.contracttype),0)),''$typedtext'',(SELECT type.hourlyrate FROM equipment LEFT JOIN type ON equipment.typeid=type.id WHERE equipment.id=''$rowid''),(SELECT type.travelrate FROM equipment LEFT JOIN type ON equipment.typeid=type.id WHERE equipment.id=''$rowid''),''1'',''$userid'',''0'')'),
 (454,'906','Dispatch: ','906','100','SELECT DISTINCT dispatch.id FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (455,'906','Equipment ID: ','907','100','SELECT DISTINCT dispatch.equipmentid FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (456,'906','Reported Date: ','906','100','SELECT DISTINCT (substr(dispatch.date,1,4)||''-''||substr(dispatch.date,5,2)||''-''||substr(dispatch.date,7,2)||'' ''||substr(dispatch.date,9,2)||'':''||substr(dispatch.date,11,2)) FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (457,'906','Reported Issue: ','909','100','SELECT DISTINCT dispatch.reportedissue FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (458,'906','Reported By: ','910','100','SELECT DISTINCT dispatch.reportedby FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (459,'906','Reported Contact: ','911','100','SELECT DISTINCT dispatch.contact FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (460,'906','Notes: ','912','100','SELECT DISTINCT dispatch.notes FROM dispatch WHERE dispatch.id=''$rowid''',''),
 (461,'906','Add User to Dispatch ','915','100','',''),
 (462,'906','SQLMenu','917','906','SELECT servicecall.id, (user.name ||'' ''||substr(servicecall.date,1,4)||''-''||substr(servicecall.date,5,2)||''-''||substr(servicecall.date,7,2) ||'' ''||servicecall.starttime ||'' h:''||servicecall.time ||'' t:''||servicecall.traveltime) AS OUTPUT FROM servicecall LEFT JOIN user ON user.id=servicecall.userid WHERE dispatchid=''$rowid'' AND servicecall.disabled=''0'' ORDER BY servicecall.date DESC',''),
 (463,'906','Status: ','914','100','SELECT DISTINCT (dispatch.status ||'' ''||status.status) AS OUTPUT FROM dispatch LEFT JOIN status ON status.id=dispatch.status WHERE dispatch.id=''$rowid''',''),
 (464,'907','Enter Equipment: ','906','906','','UPDATE OR IGNORE dispatch SET equipmentid=''$typedtext'' WHERE dispatch.id=''$rowid'''),
 (465,'908','Enter Date: ','906','906','','UPDATE OR IGNORE dispatch SET date=replace(replace(replace(replace((''$typedtext''),''-'',''''),'' '',''''),''.'',''''),'':'','''') WHERE dispatch.id=''$rowid'''),
 (466,'909','Enter Issue: ','906','906','','UPDATE OR IGNORE dispatch SET reportedissue=''$typedtext'' WHERE dispatch.id=''$rowid'''),
 (467,'910','Enter Person who called in: ','906','906','','UPDATE OR IGNORE dispatch SET reportedby=''$typedtext'' WHERE dispatch.id=''$rowid'''),
 (468,'911','Enter Phone: ','906','906','','UPDATE OR IGNORE dispatch SET contact=''$typedtext'' WHERE dispatch.id=''$rowid'''),
 (469,'912','Enter Notes: ','906','906','','UPDATE OR IGNORE dispatch SET notes=''$typedtext'' WHERE dispatch.id=''$rowid'''),
 (470,'913','Search Dispatch: ','913a','913a','','c'),
 (471,'913a','SQLMenu','906','100','SELECT dispatch.id,(dispatch.id||'' ''||equipmentid||'' ''||reportedby||'' ''||reportedissue||'' ''||contact||'' ''||notes) AS OUTPUT FROM dispatch WHERE dispatch.status=''3'' AND (dispatch.id LIKE ''%$rowid%'' OR equipmentid LIKE ''%$rowid%'' OR reportedissue LIKE ''%$rowid%'' OR reportedby LIKE ''%$rowid%'' OR contact LIKE ''%$rowid%'') LIMIT 14',''),
 (472,'915','Enter Dispatched User: ','916','916','','c'),
 (473,'916','SQLMenu','917b','100','SELECT user.id,(''id:''||user.id||'' login:''||login||'' name:''||user.name||'' fullname:''||fullname||'' p:''||phone||'' e:''||user.email||'' ''||privilege) AS OUTPUT FROM user WHERE user.name LIKE ''%$rowid%'' OR login LIKE ''%$rowid%'' OR fullname LIKE ''%$rowid%'' OR user.email LIKE ''%$rowid%'' OR phone LIKE ''%$rowid%'' LIMIT 14',''),
 (474,'917b','Enter Onsite Date:','906','906','SELECT dispatch.id,(dispatch.id||'' ''||equipmentid||'' ''||reportedby||'' ''||reportedissue||'' ''||contact||'' ''||notes) AS OUTPUT FROM dispatch WHERE dispatch.id=''$pprowid''','INSERT OR IGNORE INTO servicecall(dispatchid,userid,date,createdby,disabled) VALUES(''$pprowid'',''$rowid'',replace(replace(replace(replace((''$typedtext''),''-'',''''),'' '',''''),''.'',''''),'':'',''''),''$userid'',''0'');UPDATE OR IGNORE dispatch SET status=''2'' WHERE dispatch.id=''$pprowid'''),
 (475,'f917b','SQLMenu','917','100','SELECT servicecall.id,servicecall.id FROM servicecall ORDER BY servicecall.id DESC LIMIT 1',''),
 (476,'914','Enter Status: ','906','906','','UPDATE OR IGNORE dispatch SET status=''$typedtext'' WHERE dispatch.id=''$rowid'''),
 (477,'917','User: ','923','906','SELECT DISTINCT (user.name ||'' id: ''||servicecall.userid) AS OUTPUT FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (478,'917','Date: ','924','906','SELECT DISTINCT substr(servicecall.date,1,4)||''-''||substr(servicecall.date,5,2)||''-''||substr(servicecall.date,7,2) FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (479,'917','Arrival: ','925','906','SELECT DISTINCT servicecall.starttime FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (480,'917','Work Hours: ','926','906','SELECT DISTINCT servicecall.time FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (481,'917','Travel Hours: ','927','906','SELECT DISTINCT servicecall.traveltime FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (482,'917','Solution: ','928','906','SELECT DISTINCT replace(servicecall.solution,char(10),char(13)||char(10)) FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (483,'917','Disabled: ','929','906','SELECT DISTINCT servicecall.disabled FROM servicecall LEFT JOIN user ON user.id = servicecall.userid LEFT JOIN dispatch ON dispatch.id = servicecall.dispatchid LEFT JOIN address ON address.id = dispatch.addressid LEFT JOIN contacts ON contacts.id = dispatch.contactid WHERE servicecall.id=''$rowid''',''),
 (484,'923','Enter User','917','917','','UPDATE OR IGNORE servicecall SET userid=''$typedtext'' WHERE servicecall.id=''$rowid'''),
 (485,'924','Enter Date','917','917','','UPDATE OR IGNORE servicecall SET date=replace(replace(replace(replace((''$typedtext''),''-'',''''),'' '',''''),''.'',''''),'':'','''') WHERE servicecall.id=''$rowid'''),
 (486,'925','Enter Arrival','917','917','','UPDATE OR IGNORE servicecall SET starttime=(SELECT (CASE length(''$typedtext'') WHEN 4 THEN ''0''||''$typedtext'' ELSE ''$typedtext'' END)) WHERE servicecall.id=''$rowid'''),
 (487,'926','Enter Work Hours','917','917','','UPDATE OR IGNORE servicecall SET time=''$typedtext'' WHERE servicecall.id=''$rowid'''),
 (488,'927','Enter Travel Hours','917','917','','UPDATE OR IGNORE servicecall SET traveltime=''$typedtext'' WHERE servicecall.id=''$rowid'';UPDATE servicecall SET travelprice=(SELECT dispatch.travelrate*servicecall.traveltime FROM servicecall LEFT JOIN dispatch ON dispatch.id=servicecall.dispatchid WHERE servicecall.id=$rowid) WHERE servicecall.id=$rowid'),
 (489,'928','Enter Solution','917','917','','UPDATE OR IGNORE servicecall SET solution=''$typedtext'' WHERE servicecall.id=''$rowid'''),
 (490,'929','','917','917','','UPDATE OR IGNORE servicecall SET disabled=CASE disabled WHEN ''1'' THEN ''0'' WHEN ''0'' THEN ''1'' ELSE ''0'' END WHERE servicecall.id=''$rowid'';UPDATE OR IGNORE dispatch SET status=''1'' WHERE dispatch.id in(SELECT servicecall.dispatchid FROM servicecall WHERE servicecall.id=''$rowid'' LIMIT 1) AND NOT EXISTS (SELECT servicecall.userid FROM servicecall WHERE servicecall.dispatchid=dispatch.id AND servicecall.disabled=''0'' LIMIT 1)'),
 (491,'100','Forms','A02','101','',''),
 (492,'A02','Create New Form','A01','100','',''),
 (493,'A01','Enter Form Name','A02','A02','','INSERT OR IGNORE INTO formfieldtitle(name,disabled) VALUES(''$typedtext'',''0'');INSERT OR IGNORE INTO formfields(fgrp,fieldname) SELECT MAX(id),formfieldtitle.name FROM formfieldtitle'),
 (494,'A02','SQLMenu','A03','100','SELECT DISTINCT formfieldtitle.id AS ids,formfieldtitle.name||'': ''||(SELECT  ifnull(group_concat(DISTINCT formfields.fieldname) ,'''') as name FROM (SELECT * FROM formfieldtitle INNER JOIN formfields ON formfields.fgrp=formfieldtitle.id) INNER JOIN formfields ON formfields.fgrp=formfieldtitle.id ) as A FROM formfieldtitle INNER JOIN formfields ON formfields.fgrp=formfieldtitle.id WHERE formfields.fgrp=formfieldtitle.id',''),
 (495,'A03','Add Field','A03b','A02','',''),
 (496,'A03','Disabled: ','A03c','A02','SELECT formfieldtitle.disabled FROM formfieldtitle WHERE formfieldtitle.id=''$rowid'' LIMIT 1',''),
 (497,'A03b','Enter Fieldname','A03','A03','','INSERT OR IGNORE INTO formfields(fgrp,fieldname) VALUES(''$rowid'',''$typedtext'')'),
 (498,'A03c','','A03','A03','','UPDATE OR IGNORE formfieldtitle SET disabled=CASE disabled WHEN ''1'' THEN ''0'' WHEN ''0'' THEN ''1'' ELSE ''0'' END WHERE formfieldtitle.id=''$rowid'''),
 (499,'A03','SQLMenu','A04','A02','SELECT DISTINCT formfields.id,(formfields.fieldname) AS A FROM formfields LEFT JOIN scf ON  scf.scfcolid=formfields.id WHERE formfields.fgrp=''$rowid'' LIMIT 99',''),
 (500,'A04','Enter Form','A05','A05','','UPDATE OR IGNORE formfields SET fieldname=''$typedtext'' WHERE formfields.id=''$rowid'''),
 (501,'A05','1','A03','A03','',''),
 (502,'100','Sales Dashboard','S00','100','',''),
 (503,'S00','SQLMenu','Q03','100','SELECT DISTINCT quote.id,(''Q''||PRINTF(''%04d'',quote.id)||'', ''||quote.quotedesc||'', C''||PRINTF(''%03d'',quote.contactid)||'', ''||'': ''||company.name||'': ''||contacts.name||'', ''||contacts.email||'', ''||contacts.cellphone) as A FROM quote LEFT JOIN contacts ON contacts.id=quote.contactid LEFT JOIN company ON company.id=contacts.companyid WHERE quote.status<2 AND quote.createdby=''$userid'' ORDER BY quote.id DESC LIMIT 5',''),
 (504,'S00','Find Quote','S29','100','',''),
 (505,'S29','Enter Quote Search Terms: ','S30','S30','','c'),
 (506,'S30','SQLMenu','Q03','S00','SELECT DISTINCT quote.id, (PRINTF(''Q%07d'',quote.id)||'' ''||quote.quotedesc||'' ''||quote.sitename||'' ''||ifnull(address.address,'''')||'' ''||contacts.name||'' ''||company.name||char(10)) AS OUTPUT FROM quote LEFT JOIN address ON address.id=quote.siteaddressid LEFT JOIN contacts ON contacts.id=quote.contactid LEFT JOIN company ON company.id=contacts.companyid WHERE company.name LIKE ''%$rowid%'' OR contacts.name LIKE ''%$rowid%'' OR address.city LIKE ''%$rowid%'' OR address.zip LIKE ''%$rowid%'' OR address.country LIKE ''%$rowid%'' OR address.state LIKE ''%$rowid%'' OR address.address LIKE ''%$rowid%'' OR quote.sitename LIKE ''%$rowid%'' OR quote.quotedesc LIKE ''%$rowid%'' OR quote.id LIKE ''%$rowid%'' ORDER BY quote.id DESC LIMIT 14',''),
 (507,'S00','New Quote','Q00','100','',''),
 (508,'S00','SQLMenu','O03','100','SELECT DISTINCT packingslip.id,(''PS''||PRINTF(''%04d'',packingslip.id)||'', ''||quote.quotedesc||'', C''||PRINTF(''%03d'',quote.contactid)||'', ''||'': ''||company.name||'': ''||contacts.name) as A FROM packingslip LEFT JOIN quote ON quote.id=packingslip.qtid LEFT JOIN contacts ON contacts.id=quote.contactid LEFT JOIN company ON company.id=contacts.companyid WHERE quote.createdby=''$userid'' ORDER BY packingslip.id DESC LIMIT 5',''),
 (509,'S00','New Packing Slip','O00','100','',''),
 (510,'O00','Enter Quote Search Terms: ','O01','O01','','c'),
 (511,'O01','SQLMenu','O03','S00','SELECT DISTINCT quote.id, (PRINTF(''Q%07d'',quote.id)||'' ''||quote.quotedesc||'' ''||quote.sitename||'' ''||ifnull(address.address,'''')||'' ''||contacts.name||'' ''||company.name||char(10)) AS OUTPUT FROM quote LEFT JOIN address ON address.id=quote.siteaddressid LEFT JOIN contacts ON contacts.id=quote.contactid LEFT JOIN company ON company.id=contacts.companyid WHERE company.name LIKE ''%$rowid%'' OR contacts.name LIKE ''%$rowid%'' OR address.city LIKE ''%$rowid%'' OR address.zip LIKE ''%$rowid%'' OR address.country LIKE ''%$rowid%'' OR address.state LIKE ''%$rowid%'' OR address.address LIKE ''%$rowid%'' OR quote.sitename LIKE ''%$rowid%'' OR quote.quotedesc LIKE ''%$rowid%'' OR quote.id LIKE ''%$rowid%'' ORDER BY quote.id DESC LIMIT 14','INSERT or IGNORE INTO packingslip(qtid,date,createdby,notes) SELECT id AS qtid,STRFTIME(''%Y%m%d%H%M'',datetime(''now'',''localtime'')),''$userid'',(''Based on Quote: ''||PRINTF(''Q%07d'',quote.id)) as A FROM quote WHERE quote.id=''$rowid'' LIMIT 1;UPDATE OR IGNORE quote SET status=3 WHERE quote.id=''$rowid'''),
 (512,'O03','Description: ','O03','S00','SELECT quote.quotedesc FROM quote LEFT JOIN packingslip ON packingslip.qtid=quote.id WHERE packingslip.id=''$rowid'' LIMIT 1',''),
 (513,'O03','','O03','S00','SELECT (''Packing Slip: ''||PRINTF(''PS%06d'',packingslip.id)||'', Quote: ''||PRINTF(''Q%07d'',quote.id)||'', ContactID:''||quote.contactid) as A FROM quote JOIN contacts ON contacts.id=quote.contactid LEFT JOIN packingslip ON packingslip.qtid=quote.id WHERE packingslip.id=''$rowid'' LIMIT 1',''),
 (514,'O03','SQLMenu','O03','S00','SELECT ''$rowid'',''Create Packing Slip'' as A WHERE NOT EXISTS(SELECT '''' FROM packingslip WHERE packingslip.qtid=''$rowid'')','INSERT or IGNORE INTO packingslip(qtid,notes) SELECT id AS qtid,(''Based on Quote: ''||PRINTF(''Q%07d'',quote.id)) as A FROM quote LEFT JOIN packingslip ON packingslip.qtid=quote.id WHERE packingslip.id=''$rowid'' LIMIT 1;UPDATE OR IGNORE quote SET status=3 WHERE quote.id=''$rowid'''),
 (515,'O03','SQLMenu','O03','S00','SELECT packingslip.qtid,(''PS: ''||PRINTF(''Q%06d'',packingslip.qtid)) AS A FROM packingslip WHERE packingslip.qtid=''$rowid'' LIMIT 1',''),
 (516,'O03','Contact Company: ','O03','S00','SELECT (company.name) as A FROM quote JOIN contacts ON contacts.id=quote.contactid LEFT JOIN company ON company.id=contacts.companyid LEFT JOIN packingslip ON packingslip.qtid=quote.id WHERE packingslip.id=''$rowid'' LIMIT 1',''),
 (517,'O03','Contact Name: ','O03','S00','SELECT (contacts.name) as A FROM quote JOIN contacts ON contacts.id=quote.contactid LEFT JOIN packingslip ON packingslip.qtid=quote.id WHERE packingslip.id=''$rowid'' LIMIT 1',''),
 (518,'O03','Contact Email: ','O03','S00','SELECT (contacts.email) as A FROM quote JOIN contacts ON contacts.id=quote.contactid LEFT JOIN packingslip ON packingslip.qtid=quote.id WHERE packingslip.id=''$rowid'' LIMIT 1',''),
 (519,'O03','Contact Phone: ','O03','S00','SELECT (contacts.cellphone) as A FROM quote JOIN contacts ON contacts.id=quote.contactid LEFT JOIN packingslip ON packingslip.qtid=quote.id WHERE packingslip.id=''$rowid'' LIMIT 1',''),
 (520,'O03','Date: ','O03','S00','SELECT packingslip.date FROM packingslip WHERE packingslip.id=''$rowid'' LIMIT 1',''),
 (521,'O03','Contract Type: ','O03','S00','SELECT contracttype.title FROM quote LEFT JOIN contracttype ON contracttype.id=quote.contracttype LEFT JOIN packingslip ON packingslip.qtid=quote.id WHERE packingslip.id=''$rowid'' LIMIT 1',''),
 (522,'O03','Billing Address: ','O03','S00','SELECT (address.address||'', ''||address.city||'', ''||address.zip||'', ''||address.country) as A FROM quote LEFT JOIN address ON address.id=quote.billingaddressid LEFT JOIN packingslip ON packingslip.qtid=quote.id WHERE packingslip.id=''$rowid'' LIMIT 1',''),
 (523,'O03','Site Name: ','O03','S00','SELECT quote.sitename FROM quote LEFT JOIN packingslip ON packingslip.qtid=quote.id WHERE packingslip.id=''$rowid'' LIMIT 1',''),
 (524,'O03','Site Address: ','O03','S00','SELECT (address.address||'', ''||address.city||'', ''||address.zip||'', ''||address.state||'', ''||address.country) as A FROM quote LEFT JOIN address ON address.id=quote.siteaddressid LEFT JOIN packingslip ON packingslip.qtid=quote.id WHERE packingslip.id=''$rowid'' LIMIT 1',''),
 (525,'O03','SQLMenu','O03','S00','SELECT qtinv.id,(inventory.name||'', Qty:''||qtinv.qty||'' - Item''||inventory.id) AS A FROM qtinv LEFT JOIN packingslip ON packingslip.qtid=qtinv.qtid LEFT JOIN inventory ON inventory.id=qtinv.inventoryid WHERE packingslip.id=''$rowid'' ORDER BY qtinv.id DESC',''),
 (526,'O03','Notes: ','O04','S00','SELECT packingslip.notes FROM packingslip WHERE packingslip.id=''$rowid'' LIMIT 1',''),
 (527,'O04','Enter Notes: ','O03','O03','','UPDATE OR IGNORE packingslip SET notes=''$typedtext'' WHERE packingslip.id=''$rowid'''),
 (528,'O03','Created by: ','O03','S00','SELECT (user.name||'', ''||''U''||PRINTF(''%01d'',quote.createdby)) AS A FROM quote LEFT JOIN user on user.id=quote.createdby LEFT JOIN packingslip ON packingslip.qtid=quote.id WHERE packingslip.id=''$rowid''',''),
 (529,'O03','Status: ','O03','S00','SELECT status.status FROM quote LEFT JOIN status ON status.id=quote.status LEFT JOIN packingslip ON packingslip.qtid=quote.id WHERE packingslip.id=''$rowid''',''),
 (530,'O03','Email Packing Slip','O05','S00','',''),
 (531,'O03','Generate PDF ','O05','S00','',''),
 (532,'O03','Email to Self ','O05','S00','',''),
 (533,'O03','Email to Quote Creator ','O05','S00','',''),
 (534,'O05','psreport','O03','','','c'),
 (535,'S00','SQLMenu','I03','100','SELECT DISTINCT invoice.id,(''I''||PRINTF(''%04d'',invoice.id)||'', ''||quote.quotedesc||'', C''||PRINTF(''%03d'',quote.contactid)||'', ''||'': ''||company.name||'': ''||contacts.name) as A FROM invoice LEFT JOIN quote ON quote.id=invoice.qtid LEFT JOIN contacts ON contacts.id=quote.contactid LEFT JOIN company ON company.id=contacts.companyid WHERE quote.createdby=''$userid'' ORDER BY invoice.id DESC LIMIT 5',''),
 (536,'S00','Find Invoice','S31','100','',''),
 (537,'S31','Enter Invoice Search Terms: ','S32','S32','','c'),
 (538,'S32','SQLMenu','I03','S00','SELECT DISTINCT invoice.id, (PRINTF(''I%07d'',invoice.id)||'' ''||PRINTF(''Q%07d'',quote.id)||'' ''||quote.quotedesc||'' ''||quote.sitename||'' ''||ifnull(address.address,'''')||'' ''||contacts.name||'' ''||company.name||char(10)) AS OUTPUT FROM invoice LEFT JOIN quote ON quote.id=invoice.qtid LEFT JOIN address ON address.id=quote.siteaddressid LEFT JOIN contacts ON contacts.id=quote.contactid LEFT JOIN company ON company.id=contacts.companyid WHERE company.name LIKE ''%$rowid%'' OR contacts.name LIKE ''%$rowid%'' OR address.city LIKE ''%$rowid%'' OR address.zip LIKE ''%$rowid%'' OR address.country LIKE ''%$rowid%'' OR address.state LIKE ''%$rowid%'' OR address.address LIKE ''%$rowid%'' OR quote.sitename LIKE ''%$rowid%'' OR quote.quotedesc LIKE ''%$rowid%'' OR invoice.notes LIKE ''%$rowid%'' OR invoice.id LIKE ''%$rowid%'' ORDER BY quote.id DESC LIMIT 14',''),
 (539,'S00','New Invoice','I00','100','',''),
 (540,'I00','Enter Quote Search Terms: ','I01','I01','','c'),
 (541,'I01','SQLMenu','I07','S00','SELECT DISTINCT quote.id, (PRINTF(''Q%07d'',quote.id)||'' ''||quote.quotedesc||'' ''||quote.sitename||'' ''||ifnull(address.address,'''')||'' ''||contacts.name||'' ''||company.name||char(10)) AS OUTPUT FROM quote LEFT JOIN address ON address.id=quote.siteaddressid LEFT JOIN contacts ON contacts.id=quote.contactid LEFT JOIN company ON company.id=contacts.companyid WHERE company.name LIKE ''%$rowid%'' OR contacts.name LIKE ''%$rowid%'' OR address.city LIKE ''%$rowid%'' OR address.zip LIKE ''%$rowid%'' OR address.country LIKE ''%$rowid%'' OR address.state LIKE ''%$rowid%'' OR address.address LIKE ''%$rowid%'' OR quote.sitename LIKE ''%$rowid%'' OR quote.quotedesc LIKE ''%$rowid%'' OR quote.id LIKE ''%$rowid%'' ORDER BY quote.id DESC LIMIT 14','INSERT or IGNORE INTO invoice(qtid,date,createdby,notes) SELECT id AS qtid,STRFTIME(''%Y%m%d%H%M'',datetime(''now'',''localtime'')),''$userid'',(''Based on Quote: ''||PRINTF(''Q%07d'',quote.id)) as A FROM quote WHERE quote.id=''$rowid'' LIMIT 1;UPDATE OR IGNORE quote SET status=3 WHERE quote.id=''$rowid'''),
 (542,'I07','','I03','I03','SELECT invoice.id,invoice.id FROM invoice ORDER BY invoice.id DESC LIMIT 1',''),
 (543,'I03','Description: ','I06','S00','SELECT invoice.desc FROM invoice WHERE invoice.id=''$rowid'' LIMIT 1',''),
 (544,'I06','Enter Description Title text: ','I03','I03','','UPDATE OR IGNORE invoice SET desc=''$typedtext'' WHERE invoice.id=''$rowid'''),
 (545,'I03','','I03','S00','SELECT (''Invoice: ''||PRINTF(''I%08d'',invoice.id)||'', Quote: ''||PRINTF(''Q%07d'',quote.id)||'', ContactID:''||quote.contactid) as A FROM quote JOIN contacts ON contacts.id=quote.contactid LEFT JOIN invoice ON invoice.qtid=quote.id WHERE invoice.id=''$rowid'' LIMIT 1',''),
 (546,'I03','SQLMenu','I03','S00','SELECT invoice.qtid,(''I: ''||PRINTF(''Q%07d'',invoice.qtid)) AS A FROM invoice WHERE invoice.qtid=''$rowid'' LIMIT 1',''),
 (547,'I03','Subtotal: ','I03','S00','SELECT ((CASE quote.currencyid WHEN ''2'' THEN '''' WHEN ''3'' THEN '''' WHEN ''4'' THEN '''' ELSE ''$'' END)||printf(''%.2f'',quote.subtotal)||'' (''||(CASE quote.currencyid WHEN ''2'' THEN '''' WHEN ''3'' THEN '''' WHEN ''4'' THEN '''' ELSE ''$'' END)||printf(''%.2f'',quote.total)||'' Total)'') AS A FROM quote LEFT JOIN invoice ON invoice.qtid=quote.id WHERE invoice.id=''$rowid'' LIMIT 1',''),
 (548,'I03','Contact Company: ','I03','S00','SELECT (company.name) as A FROM quote JOIN contacts ON contacts.id=quote.contactid LEFT JOIN company ON company.id=contacts.companyid LEFT JOIN invoice ON invoice.qtid=quote.id WHERE invoice.id=''$rowid'' LIMIT 1',''),
 (549,'I03','Contact Name: ','I03','S00','SELECT (contacts.name) as A FROM quote JOIN contacts ON contacts.id=quote.contactid LEFT JOIN invoice ON invoice.qtid=quote.id WHERE invoice.id=''$rowid'' LIMIT 1',''),
 (550,'I03','Contact Email: ','I03','S00','SELECT (contacts.email) as A FROM quote JOIN contacts ON contacts.id=quote.contactid LEFT JOIN invoice ON invoice.qtid=quote.id WHERE invoice.id=''$rowid'' LIMIT 1',''),
 (551,'I03','Contact Phone: ','I03','S00','SELECT (contacts.cellphone) as A FROM quote JOIN contacts ON contacts.id=quote.contactid LEFT JOIN invoice ON invoice.qtid=quote.id WHERE invoice.id=''$rowid'' LIMIT 1',''),
 (552,'I03','Date: ','I03','S00','SELECT DISTINCT (substr(invoice.date,1,4)||''-''||substr(invoice.date,5,2)||''-''||substr(invoice.date,7,2)||'' ''||substr(invoice.date,9,2)||'':''||substr(invoice.date,11,2)) FROM invoice WHERE invoice.id=''$rowid'' LIMIT 1',''),
 (553,'I03','Contract Type: ','I03','S00','SELECT contracttype.title FROM quote LEFT JOIN contracttype ON contracttype.id=quote.contracttype LEFT JOIN invoice ON invoice.qtid=quote.id WHERE invoice.id=''$rowid'' LIMIT 1',''),
 (554,'I03','Billing Address: ','I03','S00','SELECT (address.address||'', ''||address.city||'', ''||address.zip||'', ''||address.country) as A FROM quote LEFT JOIN address ON address.id=quote.billingaddressid LEFT JOIN invoice ON invoice.qtid=quote.id WHERE invoice.id=''$rowid'' LIMIT 1',''),
 (555,'I03','Site Name: ','I03','S00','SELECT quote.sitename FROM quote LEFT JOIN invoice ON invoice.qtid=quote.id WHERE invoice.id=''$rowid'' LIMIT 1',''),
 (556,'I03','Site Address: ','I03','S00','SELECT (address.address||'', ''||address.city||'', ''||address.zip||'', ''||address.state||'', ''||address.country) as A FROM quote LEFT JOIN address ON address.id=quote.siteaddressid LEFT JOIN invoice ON invoice.qtid=quote.id WHERE invoice.id=''$rowid'' LIMIT 1',''),
 (557,'I03','SQLMenu','I03','S00','SELECT qtinv.id,(inventory.name||'', Qty:''||qtinv.qty||'' - Item''||inventory.id) AS A FROM qtinv LEFT JOIN invoice ON invoice.qtid=qtinv.qtid LEFT JOIN inventory ON inventory.id=qtinv.inventoryid WHERE invoice.id=''$rowid'' ORDER BY qtinv.id DESC',''),
 (558,'I03','Notes: ','I04','S00','SELECT invoice.notes FROM invoice WHERE invoice.id=''$rowid'' LIMIT 1',''),
 (559,'I04','Enter Notes: ','I03','I03','','UPDATE OR IGNORE invoice SET notes=''$typedtext'' WHERE invoice.id=''$rowid'''),
 (560,'I03','Created by: ','I03','S00','SELECT (user.name||'', ''||''U''||PRINTF(''%01d'',quote.createdby)) AS A FROM quote LEFT JOIN user on user.id=quote.createdby LEFT JOIN invoice ON invoice.qtid=quote.id WHERE invoice.id=''$rowid''',''),
 (561,'I03','Status: ','I03','S00','SELECT status.status FROM quote LEFT JOIN status ON status.id=quote.status LEFT JOIN invoice ON invoice.qtid=quote.id WHERE invoice.id=''$rowid''',''),
 (562,'I03','Email Invoice','I05','S00','',''),
 (563,'I03','Generate PDF ','I05','S00','',''),
 (564,'I03','Email to Self ','I05','S00','',''),
 (565,'I03','Email to Quote Creator ','I05','S00','',''),
 (566,'I05','invoice','I03','S00','','c'),
 (567,'S00','New Purchase Order','S00','100','',''),
 (568,'S00','New Receipt','S00','100','',''),
 (569,'S00','Edit Terms','T01','100','',''),
 (570,'S00','Add to Sales Inventory','S11','100','',''),
 (571,'S00','Find in Sales Inventory','S16','100','',''),
 (572,'S00','SQLMenu','S10','100','SELECT inventory.id,(''Item''||inventory.id||'':''||inventory.name||'', qty:''||qty) AS OUTPUT FROM inventory LEFT JOIN shelf ON shelf.id=inventory.shelfid WHERE disabled=''0'' AND inventory.shelfid=''0'' ORDER BY PRINTF(''%03d'',inventory.id) DESC LIMIT 14',''),
 (573,'S11','Enter Sales Item Name: ','S10','S10','SELECT DISTINCT inventory.id,inventory.id FROM inventory WHERE inventory.name=''$typedtext''','UPDATE OR IGNORE sqlite_sequence SET seq=seq+1 WHERE name=''salesinventoryid'';INSERT OR IGNORE INTO inventory(id,name,shelfid,qty,notes,createdby,disabled) VALUES((SELECT seq FROM sqlite_sequence WHERE name=''salesinventoryid'' LIMIT 1),''$typedtext'',''0'',''0'','''',''$userid'',''0'')'),
 (574,'S10','Item','S10','S00','SELECT DISTINCT inventory.id FROM inventory WHERE inventory.id=''$rowid''',''),
 (575,'S10','Name: ','S13','S00','SELECT DISTINCT inventory.name FROM inventory WHERE inventory.id=''$rowid''',''),
 (576,'S10','Location: ','S14','S00','SELECT shelf.name FROM shelf LEFT JOIN inventory ON inventory.shelfid=shelf.id WHERE inventory.id=''$rowid'' LIMIT 1',''),
 (577,'S10','Qty: ','S18','S00','SELECT inventory.qty FROM inventory WHERE inventory.id=''$rowid'' LIMIT 1',''),
 (578,'S10','Cost: ','S19','S00','SELECT DISTINCT inventory.cost FROM inventory WHERE inventory.id=''$rowid''',''),
 (579,'S10','Price: ','S20','S00','SELECT DISTINCT inventory.price FROM inventory WHERE inventory.id=''$rowid''',''),
 (580,'S10','Supplier: ','S26','S00','SELECT DISTINCT (company.name||'', ''||company.email||'', ''||company.officephone) AS A FROM inventory LEFT JOIN company ON company.id=inventory.supplierid WHERE inventory.id=''$rowid''',''),
 (581,'S10','Charge Tax: ','S22','S00','SELECT DISTINCT inventory.plustax FROM inventory WHERE inventory.id=''$rowid''',''),
 (582,'S10','Notes: ','S23','S00','SELECT DISTINCT replace(inventory.notes,char(10),char(13)||char(10)) FROM inventory WHERE inventory.id=''$rowid''',''),
 (583,'S23','Enter notes','S24','S24','','UPDATE OR IGNORE inventory SET notes=''$typedtext'' WHERE inventory.id=''$rowid'''),
 (584,'S24','ml','S24','S25','SELECT replace(inventory.notes,char(10),char(13)||char(10)),inventory.notes FROM inventory WHERE inventory.id=''$rowid''','UPDATE OR IGNORE inventory SET notes=(SELECT DISTINCT inventory.notes FROM inventory WHERE inventory.id=''$rowid'')||''$typedtext''||char(10) WHERE inventory.id=''$rowid'''),
 (585,'S25','','S10','S10','','UPDATE OR IGNORE inventory SET notes=(SELECT DISTINCT trim(inventory.notes,char(10)) FROM inventory WHERE inventory.id=''$rowid'') WHERE inventory.id=''$rowid'''),
 (586,'S10','Created by: ','S10','S00','SELECT (user.name||'', ''||''U''||PRINTF(''%01d'',terms.createdby)) AS A FROM terms LEFT JOIN user on user.id=terms.createdby WHERE terms.id=''$rowid''',''),
 (587,'S10','Disabled: ','S17','S00','SELECT DISTINCT disabled FROM inventory WHERE inventory.id=''$rowid''',''),
 (588,'S13','Enter Item Name: ','S10','S10','','UPDATE OR IGNORE inventory SET name=''$typedtext'' WHERE inventory.id=''$rowid'''),
 (589,'S14','Add New Shelf','S14b','S10','',''),
 (590,'S14b','Enter Shelf Name: ','S14','S14','SELECT ''$typedtext'',''$typedtext''','INSERT OR IGNORE INTO shelf(name,barcode) VALUES(''$typedtext'',abs(random() % 9000))'),
 (591,'S14','SQLMenu','S15','S10','SELECT shelf.id,shelf.name FROM shelf','UPDATE OR IGNORE inventory SET shelfid=''$rowid'' WHERE inventory.id=''$prowid'''),
 (592,'S15','1','S10','S10','',''),
 (593,'S16','Search Item: ','S17','S17','','c'),
 (594,'S17','SQLMenu','S10','S00','SELECT inventory.id,(inventory.name||'' '') AS OUTPUT FROM inventory WHERE inventory.id LIKE ''%$rowid%'' OR inventory.name LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE inventory SET shelfid=''$rowid'' WHERE inventory.id=''$pprowid'''),
 (595,'S18','UPDATE OR IGNORE Total Quantity: ','S10','S10','','UPDATE OR IGNORE inventory SET qty=''$typedtext'' WHERE inventory.id=''$rowid'''),
 (596,'S19','UPDATE OR IGNORE Cost: ','S10','S10','','UPDATE OR IGNORE inventory SET cost=''$typedtext'' WHERE inventory.id=''$rowid'''),
 (597,'S20','UPDATE OR IGNORE Price: ','S10','S10','','UPDATE OR IGNORE inventory SET price=''$typedtext'' WHERE inventory.id=''$rowid'''),
 (598,'S22','UPDATE OR IGNORE Plustax: ','S10','S10','','UPDATE OR IGNORE inventory SET plustax=''$typedtext'' WHERE inventory.id=''$rowid'''),
 (599,'S26','Search Company Name: ','S27','S27','','c'),
 (600,'S27','SQLMenu','S28','S00','SELECT company.id,(company.name ||'' ''||company.email ||'' ''||company.officephone||'' ''||company.cellphone) AS OUTPUT FROM company WHERE company.name LIKE ''%$rowid%'' OR company.email LIKE ''%$rowid%'' OR company.officephone LIKE ''%$rowid%'' OR company.cellphone LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE inventory SET supplierid=''$rowid'' WHERE inventory.id=''$pprowid'''),
 (601,'S28','2','S10','S10','',''),
 (602,'T01','Add terms','T02','100','',''),
 (603,'T01','Find terms','T08','100','',''),
 (604,'T02','Enter Title: ','T03','T03','SELECT terms.id,terms.id FROM terms ORDER BY terms.id DESC LIMIT 1','INSERT OR IGNORE INTO terms(title,createdby) VALUES(''$typedtext'',''$userid'')'),
 (605,'T01','SQLMenu','T03','T01','SELECT terms.id,(''T''||PRINTF(''%02d'',terms.id)||'': ''||title) AS A FROM terms ORDER BY terms.id DESC LIMIT 14',''),
 (606,'T03','ID: ','T03','T01','SELECT $rowid,$rowid LIMIT 1',''),
 (607,'T03','Title: ','T04','T01','SELECT DISTINCT title FROM terms WHERE terms.id=''$rowid'' LIMIT 1',''),
 (608,'T03','Description:','T05','T01','SELECT (char(13)||char(10)||''    ''||replace(terms.desc,char(10),char(13)||char(10)||''    '')) FROM terms WHERE terms.id=''$rowid''',''),
 (609,'T03','Created by: ','T03','T01','SELECT (user.name||'', ''||''U''||PRINTF(''%01d'',terms.createdby)) AS A FROM terms LEFT JOIN user on user.id=terms.createdby WHERE terms.id=''$rowid''',''),
 (610,'T04','Enter Title: ','T03','T03','','UPDATE OR IGNORE terms SET title=''$typedtext'' WHERE terms.id=''$rowid'''),
 (611,'T05','Enter Agreement Term Text: ','T06','T06','','UPDATE OR IGNORE terms SET desc=''$typedtext'' WHERE terms.id=''$rowid'''),
 (612,'T06','ml','T06','T07','SELECT replace(terms.desc,char(10),char(13)||char(10)),terms.desc FROM terms WHERE terms.id=''$rowid''','UPDATE OR IGNORE terms SET desc=(SELECT DISTINCT terms.desc FROM terms WHERE terms.id=''$rowid'')||''$typedtext''||char(10) WHERE terms.id=''$rowid'''),
 (613,'T07','','T03','T03','','UPDATE OR IGNORE terms SET desc=(SELECT DISTINCT trim(terms.desc,char(10)) FROM terms WHERE terms.id=''$rowid'') WHERE terms.id=''$rowid'''),
 (614,'T08','Search terms: ','T09','T09','','c'),
 (615,'T09','SQLMenu','T03','T01','SELECT terms.id,(terms.id||'' ''||title) AS OUTPUT FROM terms WHERE terms.id LIKE ''%$rowid%'' OR title LIKE ''%$rowid%'' LIMIT 14',''),
 (616,'Q00','Enter Contact Name: ','Q01','Q01','','c'),
 (617,'Q01','SQLMenu','Q02','100','SELECT DISTINCT contacts.id, (contacts.name||'' ''||company.name||char(10)) AS OUTPUT FROM contacts LEFT JOIN company ON company.id=contacts.companyid WHERE company.name LIKE ''%$rowid%'' OR contacts.name LIKE ''%$rowid%'' ORDER BY contacts.id DESC LIMIT 14',''),
 (618,'Q02','Enter Description Title text: ','Q03','Q03','SELECT quote.id,quote.id FROM quote ORDER BY quote.id DESC LIMIT 1','INSERT OR IGNORE INTO quote(contactid,quotedesc,date,expirydate,startdate,enddate,contracttype,billingaddressid,status,plustax,createdby,disabled) VALUES(''$rowid'',''$typedtext'',STRFTIME(''%Y%m%d'',datetime(''now'',''localtime'')),STRFTIME(''%Y%m%d'',datetime(''now'',''localtime''),''+90 days''),STRFTIME(''%Y%m%d'',date(''now'',''start of month'',''+1 month'')),STRFTIME(''%Y%m%d'',date(''now'',''start of month'',''+13 month'',''-1 day'')),0,(SELECT contacts.addressid from contacts WHERE contacts.id=''$rowid''),1,(SELECT company.plustax FROM contacts LEFT JOIN company ON company.id=contacts.companyid WHERE contacts.id=$rowid),''$userid'',''0'')'),
 (619,'Q03','Description: ','Q64','S00','SELECT quote.quotedesc FROM quote WHERE quote.id=''$rowid'' LIMIT 1',''),
 (620,'Q64','Enter Description Title text: ','Q03','Q03','','UPDATE OR IGNORE quote SET quotedesc=''$typedtext'''),
 (621,'Q03','','Q03','S00','SELECT (''Quote: ''||PRINTF(''Q%07d'',quote.id)||'', ContactID:''||quote.contactid) as A FROM quote JOIN contacts ON contacts.id=quote.contactid WHERE quote.id=''$rowid'' LIMIT 1',''),
 (622,'Q03','SQLMenu','Q03','S00','SELECT ''$rowid'',''Create Packing Slip'' as A WHERE NOT EXISTS(SELECT '''' FROM packingslip WHERE packingslip.qtid=''$rowid'')','INSERT or IGNORE INTO packingslip(qtid,date,createdby,notes) SELECT id AS qtid,STRFTIME(''%Y%m%d%H%M'',datetime(''now'',''localtime'')),''$userid'',(''Based on Quote: ''||PRINTF(''Q%07d'',quote.id)) as A FROM quote WHERE quote.id=''$rowid'' LIMIT 1;UPDATE OR IGNORE quote SET status=3 WHERE quote.id=''$rowid'''),
 (623,'Q03','SQLMenu','Q62','S00','SELECT packingslip.qtid,(''PS: ''||packingslip.qtid) AS A FROM packingslip WHERE packingslip.qtid=''$rowid'' LIMIT 1',''),
 (624,'Q03','SQLMenu','Q03','S00','SELECT ''$rowid'',''Create Invoice'' as A WHERE NOT EXISTS(SELECT '''' FROM invoice WHERE invoice.qtid=''$rowid'')','INSERT or IGNORE INTO invoice(qtid,notes,date) SELECT quote.id,(''Based on Quote: ''||PRINTF(''Q%07d'',quote.id)),STRFTIME(''%Y%m%d%H%M'',datetime(''now'',''localtime'')) AS A FROM quote LEFT JOIN invoice ON invoice.qtid=quote.id WHERE quote.id=''$rowid'' LIMIT 1;UPDATE OR IGNORE quote SET status=3 WHERE quote.id=''$rowid'''),
 (625,'Q03','SQLMenu','I03','S00','SELECT invoice.id,(''Recent Invoice: ''||PRINTF(''I%07d'',invoice.id)) AS A FROM invoice WHERE invoice.qtid=''$rowid'' ORDER by invoice.id DESC LIMIT 10',''),
 (626,'Q62','','O03','O03','SELECT packingslip.id,packingslip.id FROM packingslip ORDER BY packingslip.id DESC LIMIT 1',''),
 (627,'Q03','Contact Company: ','Q14','S00','SELECT (company.name) as A FROM quote JOIN contacts ON contacts.id=quote.contactid LEFT JOIN company ON company.id=contacts.companyid WHERE quote.id=''$rowid'' LIMIT 1',''),
 (628,'Q03','Contact Name: ','Q17','S00','SELECT (contacts.name) as A FROM quote JOIN contacts ON contacts.id=quote.contactid WHERE quote.id=''$rowid'' LIMIT 1',''),
 (629,'Q03','Contact Email: ','Q19','S00','SELECT (contacts.email) as A FROM quote JOIN contacts ON contacts.id=quote.contactid WHERE quote.id=''$rowid'' LIMIT 1',''),
 (630,'Q03','Contact Phone: ','Q21','S00','SELECT (contacts.cellphone) as A FROM quote JOIN contacts ON contacts.id=quote.contactid WHERE quote.id=''$rowid'' LIMIT 1',''),
 (631,'Q03','Date: ','Q23','S00','SELECT substr(quote.date,1,4)||''-''||substr(quote.date,5,2)||''-''||substr(quote.date,7,2) FROM quote WHERE quote.id=''$rowid'' LIMIT 1',''),
 (632,'Q03','Contract Type: ','Q24','S00','SELECT contracttype.title FROM quote LEFT JOIN contracttype ON contracttype.id=quote.contracttype WHERE quote.id=''$rowid'' LIMIT 1',''),
 (633,'Q03','Billing Address: ','Q26','S00','SELECT (address.address||'', ''||address.city||'', ''||address.zip||'', ''||address.country) as A FROM quote LEFT JOIN address ON address.id=quote.billingaddressid WHERE quote.id=''$rowid'' LIMIT 1',''),
 (634,'Q03','Site Name: ','Q28','S00','SELECT quote.sitename FROM quote WHERE quote.id=''$rowid'' LIMIT 1',''),
 (635,'Q03','Site Address: ','Q29','S00','SELECT (address.address||'', ''||address.city||'', ''||address.zip||'', ''||address.state||'', ''||address.country) as A FROM quote LEFT JOIN address ON address.id=quote.siteaddressid WHERE quote.id=''$rowid'' LIMIT 1',''),
 (636,'Q03','SQLMenu','Q48','S00','SELECT $rowid,''Create Service Contract''','INSERT or IGNORE INTO qtscope(typeid,qtid) SELECT DISTINCT equipment.typeid,$rowid FROM equipment LEFT JOIN quote ON quote.contactid=equipment.contactid WHERE quote.id=$rowid AND equipment.typeid NOT IN(SELECT DISTINCT equipment.typeid FROM equipment LEFT JOIN quote ON quote.contactid=equipment.contactid LEFT JOIN qtscope on qtscope.qtid=quote.id WHERE quote.id=$rowid AND qtscope.typeid=equipment.typeid AND equipment.contactid=quote.contactid)'),
 (637,'Q03','SQLMenu','Q48','S00','SELECT qtscope.id,(''Remove from Contract: ''||type.name||'' Qty:''||count(equipment.id)) AS A FROM qtscope LEFT JOIN quote ON quote.id=qtscope.qtid LEFT JOIN type ON type.id=qtscope.typeid LEFT JOIN equipment ON equipment.typeid=qtscope.typeid WHERE quote.contactid=equipment.contactid AND qtscope.qtid=$rowid  GROUP BY qtscope.id ORDER BY type.name ASC','DELETE FROM qtscope WHERE qtscope.id=$rowid'),
 (638,'Q03','Add Item Number from Sales Inventory','Q55','S00','',''),
 (639,'Q03','Add from User Inventory','Q51','S00','',''),
 (640,'Q03','SQLMenu','Q44','S00','SELECT qtinv.id,(inventory.name||'', Qty:''||qtinv.qty||'' - Item''||inventory.id) AS A FROM qtinv LEFT JOIN inventory ON inventory.id=qtinv.inventoryid WHERE qtinv.qtid=''$rowid'' ORDER BY qtinv.id DESC',''),
 (641,'Q44','Part: ','Q44','Q03','SELECT (inventory.id||'' - ''||inventory.name) AS A FROM qtinv LEFT JOIN inventory ON inventory.id=qtinv.inventoryid WHERE qtinv.id=''$rowid'' LIMIT 1',''),
 (642,'Q44','Qty: ','Q58','Q03','SELECT (qtinv.qty) AS A FROM qtinv WHERE qtinv.id=''$rowid'' LIMIT 1',''),
 (643,'Q44','Cost: ','Q45','Q03','SELECT (''$''||printf(''%.2f'',qtinv.cost)) AS A FROM qtinv WHERE qtinv.id=''$rowid'' LIMIT 1',''),
 (644,'Q44','Price: ','Q46','Q03','SELECT (''$''||printf(''%.2f'',qtinv.price)) AS A FROM qtinv WHERE qtinv.id=''$rowid'' LIMIT 1',''),
 (645,'Q44','Subtotal: ','Q46b','Q03','SELECT (''$''||printf(''%.2f'',qtinv.subtotal)||'' (''||printf(''%.2f'',qtinv.total)||'' Total)'') AS A FROM qtinv WHERE qtinv.id=''$rowid'' LIMIT 1',''),
 (646,'Q44','Notes: ','Q46c','Q03','SELECT (qtinv.notes) AS A FROM qtinv LEFT JOIN inventory ON inventory.id=qtinv.inventoryid WHERE qtinv.id=''$rowid'' LIMIT 1',''),
 (647,'Q44','Add Taxes: ','Q59','Q03','SELECT (CASE qtinv.plustax WHEN ''1'' THEN ''YES'' ELSE ''NO'' END) AS A FROM qtinv WHERE qtinv.id=''$rowid'' LIMIT 1',''),
 (648,'Q44','Created by: ','Q44','Q03','SELECT (user.name||'', ''||''U''||PRINTF(''%01d'',qtinv.createdby)) AS A FROM qtinv LEFT JOIN user ON user.id=qtinv.createdby WHERE qtinv.id=''$rowid'' LIMIT 1',''),
 (649,'Q44','Put into Own Inventory','Q47','Q03','',''),
 (650,'Q45','Enter Part Cost','Q57','Q57','','UPDATE OR IGNORE qtinv SET cost=''$typedtext'' WHERE qtinv.id=''$rowid'''),
 (651,'Q46','Enter Part Price','Q57','Q57','','UPDATE OR IGNORE qtinv SET price=''$typedtext'' WHERE qtinv.id=''$rowid'''),
 (652,'Q46b','Override Part Total Price: ','Q44','Q44','','UPDATE OR IGNORE qtinv SET total=''$typedtext'',subtotal=''$typedtext'' WHERE qtinv.id=''$rowid'''),
 (653,'Q46c','Enter Part Notes','Q44','Q44','','UPDATE OR IGNORE qtinv SET notes=''$typedtext'' WHERE qtinv.id=''$rowid'''),
 (654,'Q47','','Q48','Q48','','INSERT or IGNORE INTO userinv(inventoryid,userid,qty,date,notes,createdby,disabled) SELECT qtinv.inventoryid,''$userid'',''0'',STRFTIME(''%Y%m%d'',datetime(''now'',''localtime'')),'''',''$userid'',''0'' FROM qtinv WHERE qtinv.id=''$rowid'' AND NOT EXISTS(SELECT userinv.inventoryid FROM userinv LEFT JOIN qtinv ON qtinv.inventoryid=userinv.inventoryid WHERE qtinv.id=''$rowid'');UPDATE OR IGNORE qtinv SET qty=qty-1 WHERE qtinv.inventoryid=(SELECT qtinv.inventoryid FROM qtinv WHERE qtinv.id=''$rowid'' LIMIT 1) AND qtinv.id=''$rowid'' AND qtinv.qty<>0;UPDATE OR IGNORE userinv SET qty=qty+1,date=STRFTIME(''%Y%m%d'',datetime(''now'',''localtime'')) WHERE userinv.inventoryid=(SELECT qtinv.inventoryid FROM qtinv WHERE qtinv.id=''$rowid'' LIMIT 1);DELETE FROM qtinv WHERE qtinv.qty=''0'' AND qtinv.id=''$rowid'';'),
 (655,'Q48','1','Q03','Q03','',''),
 (656,'Q51','','Q52','Q52','SELECT ''$rowid'',''$rowid''',''),
 (657,'Q52','SQLMenu','Q53','Q03','SELECT userinv.id,(userinv.inventoryid||'' - ''||inventory.name||'', qty:''||userinv.qty) AS OUTPUT FROM userinv LEFT JOIN inventory ON inventory.id=userinv.inventoryid WHERE userinv.userid=''$userid'' LIMIT 99',''),
 (658,'Q53','','Q54','Q54','','UPDATE OR IGNORE quote SET supplierid=(SELECT inventory.supplierid FROM inventory LEFT JOIN userinv ON userinv.id=''$rowid'' WHERE inventory.id=userinv.inventoryid LIMIT 1) WHERE quote.id=''$prowid'';;;INSERT or IGNORE INTO qtinv(inventoryid,qtid,qty,notes,createdby,disabled) SELECT userinv.inventoryid,''$pprowid'',''0'','''',''$userid'',''0'' FROM userinv WHERE userinv.id=''$rowid'' AND NOT EXISTS(SELECT qtinv.inventoryid FROM qtinv LEFT JOIN userinv ON userinv.inventoryid=qtinv.inventoryid WHERE userinv.id=''$rowid'' AND qtinv.qtid=''$prowid'');UPDATE OR IGNORE userinv SET qty=qty-1 WHERE userinv.inventoryid=(SELECT userinv.inventoryid FROM userinv WHERE userinv.id=''$rowid'' LIMIT 1) AND userinv.id=''$rowid'' AND userinv.qty<>0;UPDATE OR IGNORE qtinv SET qty=qty+1 WHERE qtinv.inventoryid=(SELECT userinv.inventoryid FROM userinv WHERE userinv.id=''$rowid'' LIMIT 1) AND qtinv.qtid=''$pprowid'';DELETE FROM userinv WHERE userinv.qty=''0'' AND userinv.id=''$rowid'';'),
 (659,'Q54','2','Q03','Q03','',''),
 (660,'Q55','Enter Sales Item ID Number: ','Q56','Q56','','INSERT or IGNORE INTO qtinv(inventoryid,qtid,qty,cost,price,plustax,notes,createdby,disabled) SELECT inventory.id,''$rowid'',0,cost,price,plustax,notes,''$userid'',''0'' FROM inventory WHERE inventory.id=''$typedtext'' AND NOT EXISTS(SELECT qtinv.inventoryid FROM qtinv LEFT JOIN inventory ON inventory.id=qtinv.inventoryid WHERE inventory.id=''$typedtext'' AND qtinv.qtid=''$rowid'');UPDATE OR IGNORE inventory SET qty=qty-1 WHERE inventory.id=(SELECT inventory.id FROM inventory WHERE inventory.id=''$typedtext'' LIMIT 1) AND inventory.id=''$typedtext'' AND inventory.qty<>0;UPDATE OR IGNORE qtinv SET qty=qty+1 WHERE qtinv.inventoryid=(SELECT inventory.id FROM inventory WHERE inventory.id=''$typedtext'' LIMIT 1) AND qtinv.qtid=''$rowid'';;UPDATE OR IGNORE quote SET supplierid=(SELECT inventory.supplierid FROM inventory WHERE inventory.id=''$typedtext'' LIMIT 1) WHERE quote.id=''$rowid'''),
 (661,'Q58','Enter Qty Amount: ','Q57','Q57','','UPDATE OR IGNORE qtinv SET qty=''$typedtext'' WHERE qtinv.id=''$rowid'''),
 (662,'Q59','','Q57','Q57','','UPDATE OR IGNORE qtinv SET plustax=CASE plustax WHEN ''1'' THEN ''0'' WHEN ''0'' THEN ''1'' ELSE ''0'' END WHERE qtinv.id=''$rowid'''),
 (663,'Q03','Add Form','Q49','S00','',''),
 (664,'Q49','SQLMenu','Q50','Q03','SELECT DISTINCT formfieldtitle.id,formfieldtitle.name FROM formfieldtitle WHERE formfieldtitle.disabled=''0''',''),
 (665,'Q50','','Q03','Q03','SELECT scformfields.qtid,scformfields.qtid FROM scformfields ORDER BY scformfields.id DESC LIMIT 1','INSERT OR IGNORE INTO scformfields(formfieldtitleid,qtid) VALUES(''$rowid'',''$prowid'');INSERT OR IGNORE INTO scf(scformfields,scfcolid,formfieldtitleid,value,qtid) SELECT (SELECT scformfields.id FROM scformfields ORDER BY scformfields.id DESC LIMIT 1),formfields.id AS scfcolid,formfields.fgrp AS formfieldtitleid,'''' AS value,''$prowid'' AS qtid FROM formfields WHERE formfields.fgrp=''$rowid'''),
 (666,'Q03','Add Taxes: ','Q43','S00','SELECT (CASE quote.plustax WHEN ''1'' THEN ''YES'' ELSE ''NO'' END)||'' ''||(SELECT ifnull(group_concat(A),(''WARNING Salestax NOT defined for: ''||state||'', ''||country)) AS A FROM (SELECT ''(''||taxname||'' ''||(taxrate*100)||''%)'' AS A,address.state AS state,address.country AS country FROM quote LEFT JOIN address ON (address.id=quote.siteaddressid AND NOT quote.siteaddressid='''') OR (address.id=quote.billingaddressid AND quote.siteaddressid='''') LEFT JOIN salestaxes ON (salestaxes.country=address.country AND salestaxes.state=address.state))) AS A FROM quote WHERE quote.id=''$rowid'' LIMIT 1',''),
 (667,'Q43','','Q56','Q56','','UPDATE OR IGNORE quote SET plustax=CASE plustax WHEN ''1'' THEN ''0'' WHEN ''0'' THEN ''1'' ELSE ''0'' END WHERE quote.id=''$rowid'''),
 (668,'Q56','','Q03','Q03','','UPDATE OR IGNORE qtinv SET subtotal=qtinv.price*qtinv.qty WHERE qtinv.qtid=''$rowid'';UPDATE OR IGNORE qtinv SET total=qtinv.price*qtinv.qty WHERE qtinv.qtid=''$rowid'';UPDATE OR IGNORE qtinv SET total=(qtinv.price*qtinv.qty)+(qtinv.price*qtinv.qty)*(SELECT sum(salestaxes.taxrate) FROM qtinv LEFT JOIN quote ON quote.id=qtinv.qtid LEFT JOIN address ON address.id=(CASE quote.siteaddressid WHEN '''' THEN quote.billingaddressid ELSE quote.siteaddressid END) LEFT JOIN salestaxes ON salestaxes.state=address.state AND salestaxes.country=address.country WHERE quote.id=''$rowid'' AND quote.plustax=''1'' group BY qtinv.id) WHERE qtinv.qtid=''$rowid'' AND qtinv.plustax=''1'';UPDATE OR IGNORE quote SET subtotal=(SELECT sum((qtinv.subtotal)) FROM qtinv LEFT JOIN quote ON quote.id=qtinv.qtid WHERE qtinv.qtid=''$rowid''),total=(SELECT sum((qtinv.total)) FROM qtinv LEFT JOIN quote ON quote.id=qtinv.qtid WHERE qtinv.qtid=''$rowid'') WHERE quote.id=''$rowid'';;;UPDATE OR IGNORE qtinv SET costsubtotal=qtinv.cost*qtinv.qty WHERE qtinv.qtid=''$rowid'';UPDATE OR IGNORE qtinv SET costtotal=qtinv.cost*qtinv.qty WHERE qtinv.qtid=''$rowid'';UPDATE OR IGNORE qtinv SET costtotal=(qtinv.cost*qtinv.qty)+(qtinv.cost*qtinv.qty)*(SELECT sum(salestaxes.taxrate) FROM qtinv LEFT JOIN quote ON quote.id=qtinv.qtid LEFT JOIN company ON company.id=quote.supplierid LEFT JOIN address ON address.id=company.addressid LEFT JOIN salestaxes ON salestaxes.state=address.state AND salestaxes.country=address.country WHERE quote.id=''$rowid'' AND quote.plustax=''1'' group BY qtinv.id) WHERE qtinv.qtid=''$rowid'' AND qtinv.plustax=''1'';UPDATE OR IGNORE quote SET costsubtotal=(SELECT sum((qtinv.costsubtotal)) FROM qtinv LEFT JOIN quote ON quote.id=qtinv.qtid WHERE qtinv.qtid=''$rowid''),costtotal=(SELECT sum((qtinv.costtotal)) FROM qtinv LEFT JOIN quote ON quote.id=qtinv.qtid WHERE qtinv.qtid=''$rowid'') WHERE quote.id=''$rowid'';'),
 (669,'Q57','','Q44','Q44','','UPDATE OR IGNORE qtinv SET subtotal=qtinv.qty*qtinv.price WHERE qtinv.id=''$rowid''; UPDATE OR IGNORE qtinv SET total=(qtinv.qty*qtinv.price) WHERE qtinv.id=''$rowid''; UPDATE OR IGNORE qtinv SET total=(qtinv.qty*qtinv.price)+qtinv.qty*qtinv.price*(SELECT sum(salestaxes.taxrate) FROM qtinv LEFT JOIN quote ON quote.id=qtinv.qtid LEFT JOIN address ON address.id=(CASE quote.siteaddressid WHEN '''' THEN quote.billingaddressid ELSE quote.siteaddressid END) LEFT JOIN salestaxes ON salestaxes.state=address.state AND salestaxes.country=address.country WHERE qtinv.id=''$rowid'' AND quote.plustax=''1'' LIMIT 1) WHERE qtinv.id=''$rowid'' AND qtinv.plustax=''1'';UPDATE OR IGNORE quote SET subtotal=(SELECT sum(qtinv.subtotal) FROM qtinv WHERE qtinv.qtid=(SELECT qtinv.qtid FROM qtinv WHERE qtinv.id=''$rowid'' LIMIT 1)) WHERE quote.id=''$prowid'';UPDATE OR IGNORE quote SET total=(SELECT sum(qtinv.total) FROM qtinv WHERE qtinv.qtid=(SELECT qtinv.qtid FROM qtinv WHERE qtinv.id=''$rowid'' LIMIT 1)) WHERE quote.id=''$prowid'';;;UPDATE OR IGNORE qtinv SET costsubtotal=qtinv.qty*qtinv.cost WHERE qtinv.id=''$rowid''; UPDATE OR IGNORE qtinv SET costtotal=(qtinv.qty*qtinv.cost) WHERE qtinv.id=''$rowid''; UPDATE OR IGNORE qtinv SET costtotal=(qtinv.qty*qtinv.cost)+qtinv.qty*qtinv.cost*(SELECT sum(salestaxes.taxrate) FROM qtinv LEFT JOIN quote ON quote.id=qtinv.qtid LEFT JOIN company ON company.id=quote.supplierid LEFT JOIN address ON address.id=company.addressid LEFT JOIN salestaxes ON salestaxes.state=address.state AND salestaxes.country=address.country WHERE qtinv.id=''$rowid'' AND quote.plustax=''1'' LIMIT 1) WHERE qtinv.id=''$rowid'' AND qtinv.plustax=''1'';UPDATE OR IGNORE quote SET costsubtotal=(SELECT sum(qtinv.costsubtotal) FROM qtinv WHERE qtinv.qtid=(SELECT qtinv.qtid FROM qtinv WHERE qtinv.id=''$rowid'' LIMIT 1)) WHERE quote.id=''$prowid'';UPDATE OR IGNORE quote SET costtotal=(SELECT sum(qtinv.costtotal) FROM qtinv WHERE qtinv.qtid=(SELECT qtinv.qtid FROM qtinv WHERE qtinv.id=''$rowid'' LIMIT 1)) WHERE quote.id=''$prowid'';'),
 (670,'Q03','Currency: ','Q31','S00','SELECT (CASE quote.currencyid WHEN ''0'' THEN ''USD'' WHEN ''1'' THEN ''CDN'' WHEN ''2'' THEN ''EUR'' ELSE quote.currencyid END) AS A FROM quote WHERE quote.id=''$rowid'' LIMIT 1',''),
 (671,'Q03','Subtotal: ','Q33','S00','SELECT ((CASE quote.currencyid WHEN ''2'' THEN '''' WHEN ''3'' THEN '''' WHEN ''4'' THEN '''' ELSE ''$'' END)||printf(''%.2f'',quote.subtotal)||'' (''||(CASE quote.currencyid WHEN ''2'' THEN '''' WHEN ''3'' THEN '''' WHEN ''4'' THEN '''' ELSE ''$'' END)||printf(''%.2f'',quote.total)||'' Total)'') AS A FROM quote WHERE quote.id=''$rowid'' LIMIT 1',''),
 (672,'Q03','Cost Subtotal: ','Q60','S00','SELECT ((CASE quote.currencyid WHEN ''2'' THEN '''' WHEN ''3'' THEN '''' WHEN ''4'' THEN '''' ELSE ''$'' END)||printf(''%.2f'',quote.costsubtotal)||'' (''||(CASE quote.currencyid WHEN ''2'' THEN '''' WHEN ''3'' THEN '''' WHEN ''4'' THEN '''' ELSE ''$'' END)||printf(''%.2f'',quote.costtotal)||'' Total)'') AS A FROM quote WHERE quote.id=''$rowid'' LIMIT 1',''),
 (673,'Q03','Hourly Rate: ','Q34','S00','SELECT quote.hourlyrate FROM quote WHERE quote.id=''$rowid'' LIMIT 1',''),
 (674,'Q03','Travel Rate: ','Q35','S00','SELECT quote.travelrate FROM quote WHERE quote.id=''$rowid'' LIMIT 1',''),
 (675,'Q03','Quote Valid Until Date: ','Q36','S00','SELECT substr(quote.expirydate,1,4)||''-''||substr(quote.expirydate,5,2)||''-''||substr(quote.expirydate,7,2) FROM quote WHERE quote.id=''$rowid'' LIMIT 1',''),
 (676,'Q03','Effective Contact Start Date: ','Q37','S00','SELECT substr(quote.startdate,1,4)||''-''||substr(quote.startdate,5,2)||''-''||substr(quote.startdate,7,2) FROM quote WHERE quote.id=''$rowid'' LIMIT 1',''),
 (677,'Q03','Effective Contact End Date: ','Q38','S00','SELECT substr(quote.enddate,1,4)||''-''||substr(quote.enddate,5,2)||''-''||substr(quote.enddate,7,2) FROM quote WHERE quote.id=''$rowid'' LIMIT 1',''),
 (678,'Q03','Preferred Maintenance Date: ','Q39','S00','SELECT substr(quote.maintenancedate,1,4)||''-''||substr(quote.maintenancedate,5,2)||''-''||substr(quote.maintenancedate,7,2) FROM quote WHERE quote.id=''$rowid'' LIMIT 1',''),
 (679,'Q03','Notes: ','Q40','S00','SELECT quote.notes FROM quote WHERE quote.id=''$rowid'' LIMIT 1',''),
 (680,'Q03','Created by: ','Q03','S00','SELECT (user.name||'', ''||''U''||PRINTF(''%01d'',quote.createdby)) AS A FROM quote LEFT JOIN user on user.id=quote.createdby WHERE quote.id=''$rowid''',''),
 (681,'Q03','Status: ','Q41','S00','SELECT status.status FROM quote LEFT JOIN status ON status.id=quote.status WHERE quote.id=''$rowid''',''),
 (682,'Q03','Terms:','Q42','S00','SELECT (''ID:''||terms.id||char(13)||char(10)||''    ''||replace(terms.desc,char(10),char(13)||char(10)||''    ''))AS A FROM quote LEFT JOIN terms ON quote.termsid=terms.id WHERE quote.id=''$rowid'' LIMIT 1',''),
 (683,'Q03','Email Quote ','Q61','S00','',''),
 (684,'Q03','Generate PDF ','Q61','S00','',''),
 (685,'Q03','Email to Self ','Q61','S00','',''),
 (686,'Q03','Email to Quote Creator ','Q61','S00','',''),
 (687,'Q14','Search Company Name: ','Q15','Q15','','c'),
 (688,'Q15','SQLMenu','Q16','Q03','SELECT contacts.id,(company.name ||'' ''||company.email ||'' ''||company.officephone||'' ''||company.cellphone) AS OUTPUT FROM company LEFT JOIN contacts ON contacts.companyid=company.id WHERE company.name LIKE ''%$rowid%'' OR company.email LIKE ''%$rowid%'' OR company.officephone LIKE ''%$rowid%'' OR company.cellphone LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE quote SET contactid=''$rowid'' WHERE quote.id=''$pprowid'''),
 (689,'Q16','2','Q03','Q03','',''),
 (690,'Q17','Search Contact Name: ','Q18','Q18','','c'),
 (691,'Q18','SQLMenu','Q16','Q03','SELECT contacts.id,(contacts.name ||'' ''||contacts.email ||'' ''||contacts.officephone||'' ''||contacts.cellphone) AS OUTPUT FROM contacts LEFT JOIN company ON company.id=contacts.companyid WHERE contacts.name LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE quote SET contactid=''$rowid'' WHERE quote.id=''$pprowid'''),
 (692,'Q19','Search Contact Email: ','Q20','Q20','','c'),
 (693,'Q20','SQLMenu','Q16','Q03','SELECT contacts.id,(contacts.name ||'' ''||contacts.email ||'' ''||contacts.officephone||'' ''||contacts.cellphone) AS OUTPUT FROM contacts LEFT JOIN company ON company.id=contacts.companyid WHERE contacts.email LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE quote SET contactid=''$rowid'' WHERE quote.id=''$pprowid'''),
 (694,'Q21','Search Contact Phone: ','Q22','Q22','','c'),
 (695,'Q22','SQLMenu','Q16','Q03','SELECT contacts.id,(contacts.name ||'' ''||contacts.email ||'' ''||contacts.officephone||'' ''||contacts.cellphone) AS OUTPUT FROM contacts LEFT JOIN company ON company.id=contacts.companyid WHERE contacts.officephone LIKE ''%$rowid%'' OR contacts.cellphone LIKE ''%$rowid%'' OR contacts.fax LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE quote SET contactid=''$rowid'' WHERE quote.id=''$pprowid'''),
 (696,'Q23','Enter Quote Date: ','Q03','Q03','','UPDATE OR IGNORE quote SET date=replace(replace(replace(replace((''$typedtext''),''-'',''''),'' '',''''),''.'',''''),'':'','''') WHERE quote.id=''$rowid'''),
 (697,'Q24','SQLMenu','Q25','Q48','SELECT contracttype.id,(contracttype.title||'' = $''||contracttype.rate) AS OUTPUT FROM contracttype','UPDATE OR IGNORE quote SET contracttype=''$rowid'' WHERE quote.id=''$prowid'''),
 (698,'Q25','1','Q03','Q03','',''),
 (699,'Q26','Search Address: ','Q27','Q27','','c'),
 (700,'Q27','SQLMenu','Q16','Q03','SELECT address.id,(address.address ||'' ''||city ||'' ''||state ||'' ''||zip) AS OUTPUT FROM address WHERE address LIKE ''%$rowid%'' OR city LIKE ''%$rowid%'' OR state LIKE ''%$rowid%'' OR zip LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE quote SET billingaddressid=''$rowid'' WHERE quote.id=''$pprowid'''),
 (701,'Q28','Enter Site Name: ','Q03','Q03','','UPDATE OR IGNORE quote SET sitename=''$typedtext'' WHERE quote.id=''$rowid'''),
 (702,'Q29','Search Address: ','Q30','Q30','','c'),
 (703,'Q30','SQLMenu','Q16','Q03','SELECT '''',''Set to blank'' UNION ALL SELECT address.id,(address.address ||'' ''||city ||'' ''||state ||'' ''||zip) AS OUTPUT FROM address WHERE address LIKE ''%$rowid%'' OR city LIKE ''%$rowid%'' OR state LIKE ''%$rowid%'' OR zip LIKE ''%$rowid%'' LIMIT 14','UPDATE OR IGNORE quote SET siteaddressid=''$rowid'' WHERE quote.id=''$pprowid'''),
 (704,'Q31','SQLMenu','Q32','Q03','SELECT 0,''USD'' AS A UNION ALL SELECT 1,''CDN'' UNION ALL SELECT 2,''EURO'' UNION ALL SELECT 3,''GBP''','UPDATE OR IGNORE quote SET currencyid=''$rowid'' WHERE quote.id=''$prowid'''),
 (705,'Q32','1','Q03','Q03','',''),
 (706,'Q33','Override SubTotal: ','Q03','Q03','','UPDATE OR IGNORE quote SET total=''$typedtext'',subtotal=''$typedtext'' WHERE quote.id=''$rowid'''),
 (707,'Q60','Override SubTotal: ','Q03','Q03','','UPDATE OR IGNORE quote SET costtotal=''$typedtext'',costsubtotal=''$typedtext'' WHERE quote.id=''$rowid'''),
 (708,'Q34','Enter Hourly Rate: ','Q03','Q03','','UPDATE OR IGNORE quote SET hourlyrate=''$typedtext'' WHERE quote.id=''$rowid'''),
 (709,'Q35','Enter Travel Rate: ','Q03','Q03','','UPDATE OR IGNORE quote SET travelrate=''$typedtext'' WHERE quote.id=''$rowid'''),
 (710,'Q36','Quote Expiry Date: ','Q03','Q03','','UPDATE OR IGNORE quote SET expirydate=replace(replace(replace(replace((''$typedtext''),''-'',''''),'' '',''''),''.'',''''),'':'','''') WHERE quote.id=''$rowid'''),
 (711,'Q37','Contract Start Date: ','Q03','Q03','','UPDATE OR IGNORE quote SET startdate=replace(replace(replace(replace((''$typedtext''),''-'',''''),'' '',''''),''.'',''''),'':'','''') WHERE quote.id=''$rowid'''),
 (712,'Q38','Contract End Date: ','Q03','Q03','','UPDATE OR IGNORE quote SET enddate=replace(replace(replace(replace((''$typedtext''),''-'',''''),'' '',''''),''.'',''''),'':'','''') WHERE quote.id=''$rowid'''),
 (713,'Q39','Preferred Maintenance Date: ','Q03','Q03','','UPDATE OR IGNORE quote SET maintenancedate=replace(replace(replace(replace((''$typedtext''),''-'',''''),'' '',''''),''.'',''''),'':'','''') WHERE quote.id=''$rowid'''),
 (714,'Q40','Enter Notes: ','Q03','Q03','','UPDATE OR IGNORE quote SET notes=''$typedtext'' WHERE quote.id=''$rowid'''),
 (715,'Q41','Status: ','Q03','Q03','','UPDATE OR IGNORE quote SET status=''$typedtext'' WHERE quote.id=''$rowid'''),
 (716,'Q42','Enter Service Agreement Term ID Number: ','Q03','Q03','','UPDATE OR IGNORE quote SET termsid=''$typedtext'' WHERE quote.id=''$rowid'''),
 (717,'Q61','qreport','Q03','','','c'),
 (718,'457','','458','401','SELECT 1,(CASE count(1) WHEN 1 THEN substr(servicecall.date,1,4)||''-''||substr(servicecall.date,5,2)||''-''||substr(servicecall.date,7,2) ELSE ''0'' END) AS A FROM servicecall WHERE servicecall.dispatchid=''$rowid'' AND substr(servicecall.date,1,4)||''-''||substr(servicecall.date,5,2)||''-''||substr(servicecall.date,7,2)=''$prowid'' GROUP BY (servicecall.status) HAVING servicecall.status',''),
 (719,'458','','459','401','','UPDATE OR IGNORE dispatch SET status= (SELECT CASE count(DISTINCT servicecall.status) WHEN 1 THEN ''3'' ELSE ''2'' END  FROM servicecall JOIN dispatch ON dispatch.id=servicecall.dispatchid WHERE servicecall.dispatchid=''$prowid'') WHERE dispatch.id=''$prowid'''),
 (720,'459','3','460','401','',''),
 (721,'460','2','454','401','',''),
 (722,'X01','Add Salestax','X10','100','',''),
 (723,'X01','Find Salestax','X08','100','',''),
 (724,'X01','SQLMenu','X03','X01','SELECT salestaxes.id,(''Country: ''||country||'', State:''||state||'', Taxname:''||taxname||'', taxrate:''||taxrate) AS OUTPUT FROM salestaxes ORDER BY salestaxes.id DESC LIMIT 14',''),
 (725,'X03','Country: ','X04','X01','SELECT DISTINCT country FROM salestaxes WHERE salestaxes.id=''$rowid''',''),
 (726,'X03','State: ','X05','X01','SELECT DISTINCT state FROM salestaxes WHERE salestaxes.id=''$rowid''',''),
 (727,'X03','Tax Name: ','X06','X01','SELECT DISTINCT taxname FROM salestaxes WHERE salestaxes.id=''$rowid''',''),
 (728,'X03','Tax Rate: ','X07','X01','SELECT DISTINCT taxrate FROM salestaxes WHERE salestaxes.id=''$rowid''',''),
 (729,'X04','Enter Country Code: ','X03','X03','','UPDATE OR IGNORE salestaxes SET country=upper(''$typedtext'') WHERE salestaxes.id=''$rowid'''),
 (730,'X05','Enter State Code: ','X03','X03','','UPDATE OR IGNORE salestaxes SET state=(CASE WHEN upper(''$typedtext'')=''N/A'' THEN '''' WHEN length(''$typedtext'')>1 THEN upper(''$typedtext'') ELSE '''' END) WHERE salestaxes.id=''$rowid'''),
 (731,'X06','Enter Tax Name: ','X03','X03','','UPDATE OR IGNORE salestaxes SET taxname=''$typedtext'' WHERE salestaxes.id=''$rowid'''),
 (732,'X07','Enter Tax Rate: ','X03','X03','','UPDATE OR IGNORE salestaxes SET taxrate=replace(upper(''$typedtext''),'' '','''') WHERE salestaxes.id=''$rowid'''),
 (733,'X08','Enter Tax search term: ','X09','X09','','c'),
 (734,'X09','SQLMenu','X03','X01','SELECT salestaxes.id,(country||'' ''||state||'' ''||taxname||'' ''||taxrate) AS OUTPUT FROM salestaxes WHERE taxname LIKE ''%$rowid%'' OR country LIKE ''%$rowid%'' OR state LIKE ''%$rowid%'' OR taxrate LIKE ''%$rowid%'' LIMIT 14',''),
 (735,'X10','Enter Country Code: ','X11','X11','SELECT ''$typedtext'',''$typedtext''',''),
 (736,'X11','Enter State Code: ','X03','X03','SELECT ''$typedtext'',''$typedtext''','INSERT OR IGNORE INTO salestaxes(country,state) VALUES(''$rowid'',''$typedtext'')'),
 (737,'W00','2','W01','W00','',''),
 (738,'W01','Add Work Type','W06','100','',''),
 (739,'W01','Find Work Type','W04','100','',''),
 (740,'W02','Work Type: ','W03','W00','SELECT DISTINCT worktype FROM worktype WHERE worktype.id=''$rowid''',''),
 (741,'W01','SQLMenu','W03','W00','SELECT worktype.id,worktype.worktype AS OUTPUT FROM worktype ORDER BY worktype.id ASC LIMIT 99',''),
 (742,'W03','Enter Worktype: ','W00','W00','','UPDATE OR IGNORE worktype SET worktype=(''$typedtext'') WHERE worktype.id=''$rowid'''),
 (743,'W04','Enter search term: ','W05','W05','','c'),
 (744,'W05','SQLMenu','W02','W00','SELECT worktype.id,worktype.worktype AS OUTPUT FROM worktype WHERE worktype.worktype LIKE ''%$rowid%'' OR worktype.id LIKE ''%$rowid%'' LIMIT 14',''),
 (745,'W06','Enter Work type text: ','W00','W00','SELECT ''$typedtext'',''$typedtext''','INSERT OR IGNORE INTO worktype(worktype) VALUES(''$typedtext'')'),
 (746,'100','Find Address','715','101','','');
INSERT INTO "terms" ("id","title","desc","createdby") VALUES (1,'term title','term desc',0),
 (2,'term 02','',0),
 (3,'term03','',0),
 (4,'title 4','1234
5678
9101112
ABCD
321',0),
 (5,'title5','abcd
efgh
ijklm
nopw
xyz',0),
 (6,'t06','- All prices are subject to applicable taxes.
- Valid while quantities last.
- This quotation is valid for 30 days.
- A deposit of 50% of the total selling price is required to place order.
- 50% of the total selling price due on delivery/installation plus applicable taxes.
- Delivery: typically, 6 to 8 weeks from order date.
- Price includes delivery to site, if applicable.
- Price includes installation, if applicable.
- Room must be completed per agreed upon checklist/drawings 24 hours prior to installation.
- Internet and network setup including equipment are the responsibility of the customer.
- It is the responsibility of the customer to provide any necessary electrical power, ductwork, steel support, area lighting, outlets and switches, cabinets, plumbing, area heating or air conditioning, flooring, booth area with lead glass, and lead walls, etc.
- The customer is responsible for meeting MOH regulations.
- Warranty does not cover consumables, software and equipment abuse, misuse, or other causes beyond the control of the seller or manufacture.
- All equipment remains the property of seller until the final invoice is paid in full.
- Deposit Cheque is non refundable',0);
INSERT INTO "type" ("id","name","hourlyrate","travelrate","billingcode","createdby","disabled") VALUES (0,'TYPE NOT SET',0,0,0,0,0),
 (1,'Commercial Gas Stove',2,3,'CGS01',0,0),
 (2,'Lamp Post',1,1,'LP01',0,0),
 (3,'Zeroturn Rider',1,1,0,0,0),
 (4,'Front Mount Tractor',1,1,0,0,0),
 (5,'Collection System',1,1,0,0,0),
 (6,'3 Bag, 10 Bushel Bagger',1,1,0,0,0),
 (7,'72" Cutting Width, Fabricated Rear Discharge Deck',29.95,10.5,0,0,0),
 (8,'Grass Catcher - Low Dump, Hopper Style  F90 Series',1,1,0,0,0),
 (9,'Boot Kit For Rck60p-F36 Deck',1,1,0,0,0),
 (10,'Hydraulic Valve, Single',1,1,0,0,0),
 (11,'Second Auxiliary Hydraulic Valve Kit',1,1,0,0,0),
 (12,'Deluxe Hard Cab Standard Features',1,1,0,0,0),
 (13,'Cab Sealing Kit For F5206 Cab',1,1,0,0,0),
 (14,'Adapter Kit - Grass Catcher Control Mount',1,1,0,0,0),
 (15,'Roof Mounted Led Strobe Light Kit',1,1,0,0,0),
 (16,'Interior Rearview Mirror',1,1,0,0,0),
 (17,'60" Rotary Sweeper',1,1,0,0,0),
 (18,'Utility Vehicle Base Model',1,1,0,0,0),
 (19,'48" Two Stage Commercial Snow Blower',1,1,0,0,0),
 (20,'4wd Compact Tractor -  2 Post Foldable Rops',1,1,0,0,0),
 (21,'60" Rotary Sweeper - Hyd. Angle, 21.5" Wafer',1,1,0,0,0),
 (22,'74" Two-Stage Utility Snowblower For All Grand L60 Models',1,1,0,0,0),
 (23,'Skid Steer Loader Basic Unit',1,1,0,0,0),
 (24,'Excavator Basic Unit',1,1,0,0,0),
 (25,'0',1,1,0,0,0),
 (26,'Chiller',1,1,0,0,0),
 (27,'Torch',1,1,0,0,0),
 (28,'Flashlight',1,1,0,0,0),
 (29,'Excavator',1,1,0,0,0),
 (30,'Skidsteer',1,1,0,0,0),
 (31,'Backpack',1,1,0,0,0);
INSERT INTO "user" ("id","name","login","fullname","phone","email","privilege","password","trustedip","menu","invmode","invbarcode","invid","createdby","disabled") VALUES (0,'Admin','admin','Administrator','none','admin@system.com',0,'a','127.0.0.12','100','D','111111110','',0,0),
 (2,'a','a','a','','',2,'a','192.168.43.16','100','D','111111111','',0,0),
 (3,'b','b','b','b16','hhhj@fhhg.com',2,'b','','100','D','111111112','',0,1),
 (4,'Albert','ab','Albert Bonny','416-123-4567','abon@email.com',2,'ab','','100','D','111111113','',0,0),
 (5,'Popeye','pe','Popeye','313-535-5555','popeye@fake.com',2,'pe','','100','D','111111114','',0,0),
 (6,'Ronald','rm','Ronald Mica','542-555-2245','rmic@home.com',2,'rm','','100','D','111111115','',0,0),
 (7,'Ricky Roker','rn','Richard Rokker','754-555-0000','rr@roker.com',4,'rn','','','D','111111116','',0,0),
 (8,'Ronaldo','ro','Ronaldo Ortez','777-333-4322','ronaldo@gmail.com',2,'ro','','100','D','111111117','',0,0),
 (9,'Armin','armin','Armin Ardvark','416-333-5555','a@f.com',3,'armin','192.168.43.99','815a','D','111111118','',0,0),
 (16,'User160','User16','User16nm','User16','User16@server.com','User16','User16n','User16','User16','D','User16','',0,'User16'),
 (17,'User17','User17','User17','User17','User17@server.com','User17','User17','User17j','User17','D','User17','',0,'User17'),
 (18,'User18','User18','User18','User18','User18@server.com','User18','User18','User18','User18','D','User18','',0,'User18'),
 (19,'User19','User19','User19','User19m','User19@server.com','User19','User19','User19','User19','D','499005076569','',0,0),
 (20,'wendy','wendy','wendy','555-55555','wendy@woork.com',2,'wendy','','100','D','096619845781','',0,0);
INSERT INTO "userinv" ("id","inventoryid","userid","qty","date","notes","createdby","disabled") VALUES (139,55555,8,5,'20230626 20:35','',0,0),
 (142,12345679,8,4,'20230317 07:59','',0,0),
 (151,55555,9,8,'20230317 08:26','',0,0),
 (168,3333,9,5,'20230612 05:35','',0,0),
 (171,55555,7,2,'20230626 20:37','',0,0),
 (172,'wasa',0,1,'20230723 11:25','',0,0),
 (176,'wasa',20,4,'2023-08-18 20:02','',0,0),
 (177,1,0,4,'20230726 06:37','',0,0),
 (178,769328100204,20,2,'2023-08-18 16:10','',2,0),
 (179,'83061144727S',20,4,'2023-08-18 20:19','',2,0),
 (180,70845004716,19,5,'2023081820:53','',2,0),
 (182,70845004716,20,1,'2023081820:53','',2,0);
INSERT INTO "worktype" ("id","worktype") VALUES (1,'Scheduled'),
 (2,'Unscheduled'),
 (3,'Emergency'),
 (4,'Remote'),
 (5,'Preventative Maintenance');
COMMIT;
