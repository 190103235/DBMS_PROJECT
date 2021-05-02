SET SERVEROUTPUT ON;

--image
ALTER TABLE travel_insurance
ADD destination_image BLOB;

SELECT * FROM travel_insurance;

--id
ALTER TABLE travel_insurance
ADD insurance_id NUMBER;

CREATE SEQUENCE id_seq
    MINVALUE 1
    START WITH 1
    INCREMENT BY 1
    CACHE 196;
--DROP SEQUENCE id_seq;

BEGIN
    FOR i IN 1 .. 196 LOOP
        UPDATE travel_insurance
        SET insurance_id = id_seq.nextval;
    END LOOP;
END;

SELECT insurance_id FROM travel_insurance;

--set pk
ALTER TABLE travel_insurance
ADD PRIMARY KEY (insurance_id);

--to get pk column
SELECT cols.table_name, cols.column_name, cols.position, cons.status, cons.owner
FROM all_constraints cons, all_cons_columns cols
WHERE cols.table_name = 'TRAVEL_INSURANCE'
AND cons.constraint_type = 'P'
AND cons.constraint_name = cols.constraint_name
AND cons.owner = cols.owner
ORDER BY cols.table_name, cols.position;

--two derived columns
ALTER TABLE travel_insurance
ADD discount_percent NUMBER;

CREATE OR REPLACE TRIGGER discount_trigg
    BEFORE INSERT OR UPDATE ON travel_insurance
    FOR EACH ROW
DECLARE
BEGIN
    IF :new.duration > 100 THEN
        :new.discount_percent := 10;
    ELSIF :new.duration > 50 THEN
        :new.discount_percent := 5;
    ELSE
        :new.discount_percent := 0;
    END IF;
END;
UPDATE travel_insurance SET agency = 'AKATSUKI' WHERE insurance_id = 1645519;
SELECT * FROM travel_insurance WHERE insurance_id = 1645519;

ALTER TABLE travel_insurance
ADD free VARCHAR2(25);

CREATE OR REPLACE TRIGGER free_trigg
    BEFORE INSERT OR UPDATE ON travel_insurance
    FOR EACH ROW
DECLARE
BEGIN
    IF :new.age > 80 THEN
        :new.free := 'TRUE';
    ELSE
        :new.free := 'FALSE';
    END IF;
END;
UPDATE travel_insurance SET agency = 'AKATSUKI' WHERE insurance_id = 1645528;
SELECT * FROM travel_insurance WHERE insurance_id = 1645528;

--technical requirements
--functions:

--find the total number of airlines
CREATE OR REPLACE FUNCTION totalAirlines
RETURN number IS  
   total number := 0;  
BEGIN  
   SELECT count(*) into total  
   FROM travel_insurance
   WHERE agency_type = 'Airlines';  
    RETURN total;  
END;  

DECLARE  
   total number;  
BEGIN  
   total := totalAirlines();  
   dbms_output.put_line('Total number of Airlines: ' || total);  
END;  

--find the total number of travel agencies
CREATE OR REPLACE FUNCTION totalTravelAgencies
RETURN number IS  
   total number := 0;  
BEGIN  
    SELECT count(*) into total  
    FROM travel_insurance
    WHERE agency_type = 'Travel Agency';  
    RETURN total;  
END;  

DECLARE  
   total number;  
BEGIN  
   total := totalTravelAgencies();  
   dbms_output.put_line('Total number of Travel Agencies: ' || total);  
END;

--calculate average duration
CREATE OR REPLACE FUNCTION calc_avg_duration
    (v_agency IN travel_insurance.agency%TYPE)
    RETURN NUMBER IS 
    v_duration travel_insurance.duration%TYPE := 0;
BEGIN
    SELECT AVG(duration)
        INTO v_duration
        FROM travel_insurance
        WHERE agency = v_agency
        GROUP BY agency;
    RETURN v_duration;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN RETURN NULL;
END calc_avg_duration;

DECLARE 
    v_duration travel_insurance.duration%TYPE;
BEGIN
    v_duration := calc_avg_duration('CBH');
    DBMS_OUTPUT.PUT_LINE(v_duration);
END;

--calculate average age
CREATE OR REPLACE FUNCTION calc_avg_age
    (v_destination IN travel_insurance.destination%TYPE)
    RETURN NUMBER IS
    v_avg_age NUMBER := 0;
BEGIN
    SELECT AVG(age)
        INTO v_avg_age
        FROM travel_insurance
        WHERE destination = v_destination
        GROUP BY destination;
    RETURN v_avg_age;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN RETURN NULL;
END calc_avg_age;

DECLARE 
    v_avg_age NUMBER;
BEGIN
    v_avg_age := calc_avg_age('JAPAN');
    DBMS_OUTPUT.PUT_LINE(FLOOR(v_avg_age));
END;

--procedures:
CREATE OR REPLACE PROCEDURE find_area_pop
    (p_insurance_id IN travel_insurance.insurance_id%TYPE,
    p_agency_type OUT travel_insurance.agency_type%TYPE,
    p_product_name OUT travel_insurance.product_name%TYPE) IS 
BEGIN 
    SELECT agency_type, product_name
    INTO p_agency_type, p_product_name
    FROM travel_insurance
    WHERE insurance_id = p_insurance_id;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('ID is : ' || p_insurance_id|| ' does not exist');
END;

DECLARE
    v_insurance_id travel_insurance.insurance_id%TYPE;
    v_agency_type travel_insurance.agency_type%TYPE;
    v_product_name travel_insurance.product_name%TYPE;
BEGIN
    v_insurance_id := 1645519; 
    find_area_pop(v_insurance_id,v_agency_type, v_product_name);
    DBMS_OUTPUT.PUT_LINE('Agency type: ' || v_agency_type);
    DBMS_OUTPUT.PUT_LINE('Product name: ' || v_product_name);
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('ID: ' || v_insurance_id|| ' does not exist');
END;

create or replace PROCEDURE ins_up(p_insurance_id IN OUT travel_insurance.insurance_id%TYPE) IS
BEGIN
    IF p_insurance_id IS NULL THEN
        INSERT INTO travel_insurance
        VALUES( 'DAAA', 'akatsuki', 'online', 'SDU', 'No',18, 'Kazakhstan','100','0','W',19, null, p_insurance_id , 0 , null);
    ELSE
        UPDATE travel_insurance
        SET agency = 'akatsuki', agency_type = 'Wow', distribution_channel = 'SDU', product_name ='DAAA', claim ='Yes', duration = 100, 
        destination = 'KZ', net_sales = '100', commision = '18', gender = 'W' , age = 19, destination_image = null, insurance_id = 2, discount_percent = 0, free = null
        WHERE insurance_id = p_insurance_id;
    END IF;
EXCEPTION WHEN NO_DATA_FOUND THEN
    INSERT INTO travel_insurance
    VALUES('DAAA', 'akatsuki', 'online', 'SDU', 'No',18, 'Kazakhstan','100','0','W',19,null, p_insurance_id , 0 , null);
END ins_up;


DECLARE
v_insurance_id travel_insurance.insurance_id%TYPE := 1;
BEGIN
  ins_up(v_insurance_id);
END;

--collections:
DECLARE 
   TYPE names_table IS TABLE OF VARCHAR2(10); 
   TYPE rating IS TABLE OF INTEGER;  
   names names_table; 
   marks rating; 
   total integer; 
BEGIN 
   names := names_table('England', 'Korea', 'Japan', 'Canada', 'Australia'); 
   marks:= rating(8, 10, 6, 7, 9); 
   total := names.count; 
   dbms_output.put_line('Total '|| total || ' countries'); 
   FOR i IN 1 .. total LOOP 
      dbms_output.put_line('Countries:'||names(i)||', ratings:' || marks(i)); 
   end loop; 
END;  

DECLARE
 CURSOR c_agencies IS 
  SELECT agency, duration, destination
  FROM travel_insurance
  ORDER BY agency ASC;
 TYPE t_agencies IS TABLE OF c_agencies%ROWTYPE
 INDEX BY travel_insurance.agency%TYPE;
 v_a_table t_agencies;
 i VARCHAR2(64);
BEGIN
 FOR agency_rec IN c_agencies LOOP
  v_a_table(agency_rec.agency) := agency_rec;
 END LOOP;
  i := v_a_table.FIRST;
 WHILE i IS NOT NULL LOOP
   DBMS_OUTPUT.PUT_LINE(v_a_table(i).agency || ' ' || v_a_table(i).duration || ' ' || v_a_table(i).destination);
    i := v_a_table.NEXT(i);
END LOOP;
END;

--cursors:
DECLARE
    CURSOR dep (v_agency VARCHAR2) IS
    SELECT agency_type, distribution_channel, net_sales, commision  FROM travel_insurance
    WHERE agency = v_agency;
    v_dep dep%ROWTYPE;
BEGIN
    OPEN dep ('CBH');
    LOOP
        FETCH dep INTO v_dep;
        EXIT WHEN dep%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_dep.agency_type|| ' ' || v_dep.distribution_channel|| ' ' || v_dep.net_sales ||' '|| v_dep.commision);
        END LOOP;
    CLOSE dep;
END;

DECLARE 
   c_agency travel_insurance.agency%type; 
   c_destination travel_insurance.destination%type; 
   c_distribution_channel travel_insurance.distribution_channel%type; 
   c_duration travel_insurance.duration%type; 
   CURSOR c_customers is 
      --SELECT agency, destination, distribution_channel FROM travel_insurance where  duration > (Select avg(duration) from travel_insurance);
SELECT agency, destination, distribution_channel, duration
FROM   travel_insurance
WHERE duration = (SELECT Max(duration) 
                 FROM   travel_insurance
                 ) ;

BEGIN 
   OPEN c_customers; 
   LOOP 
   FETCH c_customers into  c_agency, c_destination, c_distribution_channel, c_duration; 
  EXIT WHEN c_customers%ROWCOUNT > 3 OR c_customers%NOTFOUND;
      dbms_output.put_line( c_agency || ' ' || c_destination || ' ' || c_distribution_channel ||' ' || c_duration); 
   END LOOP; 
   CLOSE c_customers; 
END;

--packages:
CREATE OR REPLACE PACKAGE agency_destination AS 
   PROCEDURE find_dest(ins_id travel_insurance.insurance_id%TYPE); 
END agency_destination; 


CREATE OR REPLACE PACKAGE BODY agency_destination AS  
   PROCEDURE find_dest(ins_id travel_insurance.insurance_id%TYPE) IS 
   a_dest travel_insurance.destination%TYPE; 
   BEGIN 
      SELECT destination INTO a_dest
      FROM travel_insurance
      WHERE insurance_id = ins_id; 
      dbms_output.put_line('Destination of agency with id'|| ins_id ||' is: ' || a_dest); 
   END find_dest; 
END agency_destination; 


DECLARE 
   code travel_insurance.insurance_id%TYPE := 1645528; 
BEGIN 
   agency_destination.find_dest(code); 
END;

CREATE OR REPLACE PACKAGE ti_product_name AS 
   PROCEDURE find_product(ins_id travel_insurance.insurance_id%TYPE); 
END ti_product_name; 

CREATE OR REPLACE PACKAGE BODY ti_product_name AS  
   PROCEDURE find_product(ins_id travel_insurance.insurance_id%TYPE) IS 
   a_product travel_insurance.product_name%TYPE; 
   BEGIN 
      SELECT product_name INTO a_product
      FROM travel_insurance
      WHERE insurance_id = ins_id; 
      dbms_output.put_line('Destination of agency with id '|| ins_id ||' is: ' || a_product); 
   END find_product; 
END ti_product_name; 

DECLARE 
   code travel_insurance.insurance_id%TYPE := 1645515; 
BEGIN 
   ti_product_name.find_product(code); 
END;

--triggers:
CREATE TABLE travel_insurance_LOG(

OPERATION_DATE DATE,
OLD_Agency VARCHAR2(26),
NEW_Agency VARCHAR2(26),

OLD_Agency_Type VARCHAR2(26),
NEW_Agency_Type VARCHAR2(26),

OLD_Distribution_Channel VARCHAR2(26),
NEW_Distribution_Channel VARCHAR2(26),

OLD_Product_Name VARCHAR2(26),
NEW_Product_Name VARCHAR2(26),

OLD_Duration NUMBER,
NEW_Duration NUMBER,

OLD_Destination VARCHAR2(26),
NEW_Destination VARCHAR2(26),

OLD_Net_Sales VARCHAR2(26),
NEW_Net_Sales VARCHAR2(26),

OLD_Commision VARCHAR2(26),
NEW_Commision VARCHAR2(26),

OLD_Gender VARCHAR2(26),
NEW_Gender VARCHAR2(26),

OLD_Age NUMBER,
NEW_Age NUMBER,


ACTION VARCHAR2(20),
AUTHOR VARCHAR2(20)
)

drop table travel_insurance_LOG


--1.
CREATE OR REPLACE TRIGGER insert_trig
AFTER INSERT ON travel_insurance FOR EACH ROW ENABLE
BEGIN
    INSERT INTO travel_insurance_log(operation_date, OLD_Agency, NEW_Agency , OLD_Agency_Type , NEW_Agency_Type , OLD_Distribution_Channel , NEW_Distribution_Channel, OLD_Product_Name ,
    NEW_Product_Name , OLD_Duration, NEW_Duration , OLD_Destination , NEW_Destination , OLD_Net_Sales , NEW_Net_Sales , OLD_Commision ,
    NEW_Commision , OLD_Gender , NEW_Gender , OLD_Age , NEW_Age , action, author)
    
    values(sysdate, null, :NEW.Agency, null, :NEW.Agency_Type, 
    null, :NEW.Distribution_Channel,
    null, :NEW.Product_Name,
    null, :NEW.Duration,
    null, :NEW.Destination,
    null, :NEW.Net_Sales,
    null, :NEW.Commision,
    null, :NEW.Gender,
    null, :NEW.Age,
    'Insert', 'akatsuki');
END;

insert into travel_insurance(Agency, Agency_Type, Distribution_Channel, Product_Name,Duration, Destination, net_Sales, Commision, Gender, Age, insurance_id ) 
values('DAAA', 'Naruto', 'Offline', 'Comprehensive Plan',100,'Konoha', '100', '10','W',18,44 );


select * from travel_insurance_log;
select * from travel_insurance;

--2.
CREATE OR REPLACE TRIGGER update_trig
AFTER UPDATE ON travel_insurance FOR EACH ROW ENABLE
BEGIN
     INSERT INTO travel_insurance_log(operation_date, OLD_Agency, NEW_Agency , OLD_Agency_Type , NEW_Agency_Type , OLD_Distribution_Channel , NEW_Distribution_Channel, OLD_Product_Name ,
    NEW_Product_Name , OLD_Duration, NEW_Duration , OLD_Destination , NEW_Destination , OLD_Net_Sales , NEW_Net_Sales , OLD_Commision ,
    NEW_Commision , OLD_Gender , NEW_Gender , OLD_Age , NEW_Age , action, author)
    
    values(sysdate, :OLD.Agency, :NEW.Agency, :OLD.Agency_Type, :NEW.Agency_Type,
    :OLD.Distribution_Channel, :NEW.Distribution_Channel,
    :OLD.Product_Name, :NEW.Product_Name,
    :OLD.Duration, :NEW.Duration,
    :OLD.Destination, :NEW.Destination,
    :OLD.Net_Sales, :NEW.Net_Sales,
    :OLD.Commision, :NEW.Commision,
    :OLD.Gender, :NEW.Gender,
    :OLD.Age, :NEW.Age,
    'Update', 'akatsuki');
END;

update travel_insurance set Agency = 'akatsuki' where Destination = 'Konoha';

select * from travel_insurance_log;
select * from travel_insurance;

--3.
CREATE OR REPLACE TRIGGER delete_trig
AFTER DELETE ON travel_insurance FOR EACH ROW ENABLE
BEGIN
     INSERT INTO travel_insurance_log(operation_date, OLD_Agency, NEW_Agency , OLD_Agency_Type , NEW_Agency_Type , OLD_Distribution_Channel , NEW_Distribution_Channel, OLD_Product_Name ,
    NEW_Product_Name , OLD_Duration, NEW_Duration , OLD_Destination , NEW_Destination , OLD_Net_Sales , NEW_Net_Sales , OLD_Commision ,
    NEW_Commision , OLD_Gender , NEW_Gender , OLD_Age , NEW_Age , action, author)
    
    values(sysdate, 
    :OLD.Agency, null,
    :OLD.Agency_Type, null,
    :OLD.Distribution_Channel, null,
    :OLD.Product_Name, null,
    :OLD.Duration, null,
    :OLD.Destination, null,
    :OLD.Net_Sales, null,
    :OLD.Commision, null,
    :OLD.Gender, null,
    :OLD.Age, null,
    
    'Delete', 'akatsuki');
END;

delete travel_insurance where Destination = 'Konoha';

select * from travel_insurance_log;
select * from travel_insurance;

--4.
CREATE OR REPLACE TRIGGER alter_trig
AFTER ALTER ON SCHEMA 
BEGIN
     INSERT INTO travel_insurance_log(operation_date, OLD_Agency, NEW_Agency , OLD_Agency_Type , NEW_Agency_Type , OLD_Distribution_Channel , NEW_Distribution_Channel, OLD_Product_Name ,
    NEW_Product_Name , OLD_Duration, NEW_Duration , OLD_Destination , NEW_Destination , OLD_Net_Sales , NEW_Net_Sales , OLD_Commision ,
    NEW_Commision , OLD_Gender , NEW_Gender , OLD_Age , NEW_Age , action, author)
    
    values(sysdate, null, null, null, null,  null,  null,  null,  null,  null,  null, null, null, null, null,  null,  null,  null,  null,  null,  null,  'Alter', 'akatsuki');
END;

alter table travel_insurance add email varchar2(30);

select * from travel_insurance_log;
select * from travel_insurance;
alter table travel_insurance drop column email; 

--dynamic sql:
CREATE OR REPLACE PROCEDURE get_travel_insurance IS
    TYPE t_dept IS TABLE OF travel_insurance%ROWTYPE INDEX BY BINARY_INTEGER;
    v_depttab t_dept;
BEGIN
    SELECT * BULK COLLECT INTO v_depttab FROM travel_insurance;
    FOR I IN v_depttab.FIRST .. v_depttab.LAST LOOP
        IF v_depttab.EXISTS(I) THEN 
            DBMS_OUTPUT.PUT_LINE(v_depttab(I).agency);
        END IF;
    END LOOP;
END get_travel_insurance;

BEGIN
    get_travel_insurance();
END;

DECLARE
 TYPE record_table IS RECORD (insurance_id travel_insurance.insurance_id%TYPE, agency travel_insurance.agency%TYPE, age travel_insurance.age%TYPE);
 TYPE t_emp IS TABLE OF record_table;
   v_emp t_emp;
BEGIN
   DELETE FROM TRAVEL_INSURANCE
   WHERE insurance_id=1706279
   RETURNING insurance_id, agency, age
   BULK COLLECT INTO v_emp;
     DBMS_OUTPUT.PUT_LINE('Deleted ' || SQL%ROWCOUNT || ' rows: ');
   FOR i IN v_emp.FIRST .. v_emp.LAST LOOP
      DBMS_OUTPUT.PUT_LINE('Agency ' || v_emp(i).agency || ' with id ' || v_emp(i).insurance_id || ' and age ' || v_emp(i).age);
   END LOOP;
END;

DECLARE 
    p_table_name VARCHAR2(30) := 'travel_insurance';
BEGIN
    EXECUTE IMMEDIATE 'UPDATE ' || p_table_name || ' SET commision=0 WHERE insurance_id =2';
END;
Select commision from travel_insurance where insurance_id=2; 