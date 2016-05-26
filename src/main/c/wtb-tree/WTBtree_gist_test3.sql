
CREATE or replace FUNCTION insert_wtraj1() RETURNS integer AS $$
DECLARE

wk char(12);

BEGIN


FOR i IN 101..150 LOOP

wk = 'kunsan000';
wk = wk || i;

EXECUTE 'INSERT INTO wtraj values(' || i || ', ' || quote_literal(wk) || ')';

END LOOP;

RETURN 1;
END;
$$ LANGUAGE plpgsql;

CREATE or replace FUNCTION insert_wtraj2() RETURNS integer AS $$
DECLARE

wk char(10);

BEGIN


FOR i IN 151..200 LOOP

wk = 'kunsan___';
wk = wk || i;

EXECUTE 'INSERT INTO wtraj values(' || i || ', ' || quote_literal(wk) || ')';

END LOOP;

RETURN 1;
END;
$$ LANGUAGE plpgsql;

CREATE or replace FUNCTION insert_wtraj3() RETURNS integer AS $$
DECLARE

wk char(10);

BEGIN


FOR i IN 201..250 LOOP

wk = 'kunsan___';
wk = wk || i;

EXECUTE 'INSERT INTO wtraj values(' || i || ', ' || quote_literal(wk) || ')';

END LOOP;

RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE or replace FUNCTION insert_wtraj4() RETURNS integer AS $$
DECLARE

wk char(10);

BEGIN


FOR i IN 251..300 LOOP

wk = 'kunsan___';
wk = wk || i;

EXECUTE 'INSERT INTO wtraj values(' || i || ', ' || quote_literal(wk) || ')';

END LOOP;

RETURN 1;
END;
$$ LANGUAGE plpgsql;

CREATE or replace FUNCTION insert_wtraj5() RETURNS integer AS $$
DECLARE

wk char(10);

BEGIN


FOR i IN 301..350 LOOP

wk = 'kunsan___';
wk = wk || i;

EXECUTE 'INSERT INTO wtraj values(' || i || ', ' || quote_literal(wk) || ')';

END LOOP;

RETURN 1;
END;
$$ LANGUAGE plpgsql;

CREATE or replace FUNCTION insert_wtraj6() RETURNS integer AS $$
DECLARE

wk char(10);

BEGIN


FOR i IN 351..400 LOOP

wk = 'kunsan___';
wk = wk || i;

EXECUTE 'INSERT INTO wtraj values(' || i || ', ' || quote_literal(wk) || ')';

END LOOP;

RETURN 1;
END;
$$ LANGUAGE plpgsql;


