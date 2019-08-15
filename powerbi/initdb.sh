#!bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" <<-EOSQL
    CREATE DATABASE ${DATABASE_NAME};
    CREATE DATABASE test;

    CREATE USER
        api_user
    WITH PASSWORD
        '${POSTGRES_PASSWORD}'
    LOGIN;
    CREATE USER
        pbi_user
    WITH PASSWORD
        '${POSTGRES_PASSWORD}'
    LOGIN;
    CREATE USER
        admin_db
    WITH PASSWORD
        '${POSTGRES_PASSWORD}'
    LOGIN CREATEDB;
    CREATE USER
        admin_role
    WITH PASSWORD
        '${POSTGRES_PASSWORD}'
    LOGIN CREATEROLE;

    \c ${DATABASE_NAME}

    CREATE TYPE
        epclist_type AS (
            epc VARCHAR(255),
            tid VARCHAR(255),
            uid VARCHAR(255)
        );
    CREATE TYPE
        biztranslist_type AS (
            biz_type VARCHAR(255),
            value VARCHAR(255)
        );
    CREATE TYPE
        map_coordinates AS (
            x VARCHAR(255),
            y VARCHAR(255),
            z VARCHAR(255)
        );
    CREATE TYPE
        map_text AS (
            extension_item_season VARCHAR(255),
            extension_order_season VARCHAR(255),
            extension_order_type VARCHAR(255),
            coordinates map_coordinates,
            locationtrust VARCHAR(255),
            readtime VARCHAR(255),
            seriel_number VARCHAR(255)
        );

    CREATE TABLE IF NOT EXISTS
        stock (
            event_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
            premise_code VARCHAR(255) DEFAULT NULL,
            quantity INT DEFAULT NULL,
            ean VARCHAR(18) DEFAULT NULL,
            sku VARCHAR(18) DEFAULT NULL,
            branch_code VARCHAR(255) DEFAULT NULL,
            branch_name VARCHAR(255) DEFAULT NULL
        );
    CREATE TABLE IF NOT EXISTS
        sales (
            event_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
            premise_code VARCHAR(255) DEFAULT NULL,
            quantity INT DEFAULT NULL,
            ean VARCHAR(18) DEFAULT NULL,
            sku VARCHAR(18) DEFAULT NULL,
            receipt_id VARCHAR(255) DEFAULT NULL
        );
    CREATE TABLE IF NOT EXISTS
        transfers (
            transfers_type VARCHAR(64) DEFAULT NULL,
            event_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
            premise_code VARCHAR(255) DEFAULT NULL,
            quantity INT DEFAULT NULL,
            ean VARCHAR(18) DEFAULT NULL,
            sku VARCHAR(18) DEFAULT NULL,
            branch_code VARCHAR(255) DEFAULT NULL,
            branch_name VARCHAR(255) DEFAULT NULL,
            asn_id VARCHAR(255) DEFAULT NULL
        );
    CREATE TABLE
        tagevent (
            bizlocation VARCHAR(255) DEFAULT NULL,
            bizstep VARCHAR(255) DEFAULT NULL,
            biztranslist biztranslist_type DEFAULT NULL::biztranslist_type,
            disposition VARCHAR(255) DEFAULT NULL,
            event_action VARCHAR(255) DEFAULT NULL,
            event_extension jsonb DEFAULT NULL::jsonb,
            event_id VARCHAR(255) DEFAULT NULL,
            event_type VARCHAR(255) DEFAULT NULL,
            epcclass VARCHAR(255) DEFAULT NULL,
            epclist epclist_type[] DEFAULT NULL::epclist_type[],
            eventtime TIMESTAMP WITH TIME ZONE,
            gtin VARCHAR[] DEFAULT NULL,
            parentid VARCHAR(255) DEFAULT NULL,
            premise VARCHAR(255) DEFAULT NULL,
            quantity integer DEFAULT NULL::int,
            readpoint VARCHAR(255) DEFAULT NULL,
            recordtime TIMESTAMP WITH TIME ZONE
        );
    CREATE TABLE
        tagstate (
            event_id VARCHAR(255) DEFAULT NULL,
            event_action VARCHAR(255) DEFAULT NULL,
            bizlocation VARCHAR(255) DEFAULT NULL,
            bizstep VARCHAR(255) DEFAULT NULL,
            disposition VARCHAR(255) DEFAULT NULL,
            epc VARCHAR(255) DEFAULT NULL,
            eventtime TIMESTAMP WITH TIME ZONE,
            firstseentime TIMESTAMP WITH TIME ZONE,
            gtin VARCHAR(255) DEFAULT NULL,
            manufacturer VARCHAR(255) DEFAULT NULL,
            manufacturingorder VARCHAR(255) DEFAULT NULL,
            objecttype VARCHAR(255) DEFAULT NULL,
            premise VARCHAR(255) DEFAULT NULL,
            readpoint VARCHAR(255) DEFAULT NULL,
            recordtime TIMESTAMP WITH TIME ZONE,
            stateparameter map_text DEFAULT NULL::map_text,
            tid VARCHAR(255) DEFAULT NULL,
            uid VARCHAR(255) DEFAULT NULL
        );
    CREATE TABLE
        log_tagevent (
            job_type VARCHAR(255) DEFAULT NULL,
            job_status VARCHAR(255) DEFAULT NULL,
            eventtime_start TIMESTAMP WITH TIME ZONE,
            eventtime_stop TIMESTAMP WITH TIME ZONE,
            bound_inf TIMESTAMP WITH TIME ZONE,
            bound_sup TIMESTAMP WITH TIME ZONE,
            page_size INT DEFAULT NULL,
            fetch_size INT DEFAULT NULL,
            nb_new_doc INT DEFAULT NULL,
            total_doc_es INT DEFAULT NULL,
            total_doc_postgres INT DEFAULT NULL,
            discrepancy INT DEFAULT NULL,
            debug_mode BOOLEAN DEFAULT NULL
        );
    CREATE TABLE IF NOT EXISTS
        calendar AS (
            SELECT
                datum AS date_actual,
                        CAST (datum AS timestamp WITH time zone) AS date_midnight,
                        CAST (datum AS timestamp WITHOUT time zone) AS date_locale,
                to_char(datum, 'TMYYYY') AS year_actual,
                'Q' || to_char(datum, 'Q') AS quartal_actual,
                TO_CHAR(datum, 'TMMM') AS month_actual,
                TO_CHAR(datum, 'TMMonth') AS month_name,
                TO_CHAR(datum, 'TMMon') AS month_name_short,
                TO_CHAR(datum, 'TMWW') AS week_of_year,
                TO_CHAR(datum, 'TMDD') AS day_actual,
                TO_CHAR(datum, 'TMDay') AS day_name,
                TO_CHAR(datum, 'TMDy') AS day_name_short,
                TO_CHAR(datum, 'TMD') AS day_of_week,
                TO_CHAR(datum, 'TMDDD') AS day_of_year,
                datum::text AS current_date_for_pbi,
                TO_CHAR(datum, 'TMMonth') AS current_month_for_pbi,
                        TO_CHAR(datum, 'TMYYYY') AS current_year_for_pbi
            FROM (
                SELECT '2017-01-01'::DATE + SEQUENCE.DAY AS datum
                FROM generate_series(0,2922) AS SEQUENCE(DAY)
                GROUP BY SEQUENCE.DAY
                ) DQ
            ORDER BY date_actual DESC
        );

    CREATE TABLE
        update_pos (
            premise_code VARCHAR(64) DEFAULT NULL,
            type_pos VARCHAR(64) DEFAULT NULL,
            date_update VARCHAR(64) DEFAULT NULL,
            checksum VARCHAR(32) DEFAULT NULL
        );

    CREATE TABLE IF NOT EXISTS
        clients (
            name character varying,
            premise_code character varying PRIMARY KEY,
            premise_name_long character varying,
            type_data character varying(4),
            timezone character varying,
            max_time_available_in_stock interval DEFAULT '259200',
            time_to_sale_fitting interval DEFAULT '14400',
            time_to_sale_search interval DEFAULT '14400',
            time_to_front interval DEFAULT '14400',
            inventory_time time without time zone DEFAULT '7:00'
        );

    CREATE TABLE IF NOT EXISTS
        alert_monitoring (
            type_refresh VARCHAR PRIMARY KEY,
            max_value INTEGER
        );

    CREATE TABLE IF NOT EXISTS
        disposition (
            disposition character varying PRIMARY KEY,
            description character varying
        );

    CREATE TABLE IF NOT EXISTS
    filtered_categories (
            category_name character varying PRIMARY KEY
        );

    CREATE TABLE
    businessproducts_category (
            category_id character varying(255),
            category_name character varying(255),
            category_type character varying(255),
            category_parent_id character varying(255)
        );

    CREATE TABLE
    businessproducts_product (
            gtin character varying(255),
            brand_code character varying(255),
            brand_label character varying(255),
            bundle_item_quantity bigint,
            color_code character varying(255),
            color_label character varying(255),
            display_gtin character varying(255),
            madein_code character varying(255),
            madein_label character varying(255),
            model_code character varying(255),
            model_label character varying(255),
            option_code character varying(255),
            option_label character varying(255),
            product_code character varying(255),
            product_label_long character varying(255),
            product_label_short character varying(255),
            season_code character varying(255),
            season_label character varying(255),
            size_code character varying(255),
            size_label character varying(255),
            vpn character varying(255),
            weight_gross_unit character varying(255),
            weight_gross_value double precision,
            weight_net_unit character varying(255),
            weight_net_value double precision,
            category_parent_id character varying(255),
            updatetime timestamp with time zone
        );

    CREATE TABLE
    statemachine_fixture (
            id character varying(255),
            isfixed boolean,
            locationid bigint,
            name character varying(255),
            tagid character varying(255),
            fixturetypeid character varying(255),
            rfidprofileid character varying(255),
            isenabled boolean,
            x bigint,
            y bigint,
            z bigint,
            qrcode character varying(255),
            "timestamp" bigint
        );

    CREATE TABLE
    statemachine_location (
            id bigint,
            addresscity character varying(255),
            addresscountry character varying(255),
            addressline1 character varying(255),
            addressline2 character varying(255),
            addressline3 character varying(255),
            addresspostalcode character varying(255),
            addressstate character varying(255),
            attributes character varying(255),
            bizlocation character varying(255),
            code character varying(255),
            hotspotzoffset bigint,
            latitude double precision,
            level character varying(255),
            longitude double precision,
            name character varying(255),
            parent bigint,
            sgln character varying(255),
            type character varying(255)
        );

    CREATE TABLE
    statemachine_path (
            id character varying(255),
            bizlocation character varying(255),
            locationid0 bigint,
            locationid1 bigint,
            locationid2 bigint,
            locationid3 bigint,
            locationid4 bigint,
            locationid5 bigint,
            locationid6 bigint,
            locationid7 bigint
        );

    CREATE TABLE
    supplychain_content_element (
            id character varying,
            containerid character varying(255),
            sscc character varying(18),
            type character varying(10),
            gtin character varying(14),
            epc character varying(255),
            quantity bigint,
            referencelistid bigint
        );

    CREATE TABLE
    supplychain_reference_list (
            id bigint,
            transactionid character varying(255),
            contentformat character varying(10),
            bizstep character varying(255),
            bizlocation character varying(255),
            creationtime timestamp with time zone,
            expirationtime timestamp with time zone,
            laststatuschange timestamp with time zone,
            status character varying(50),
            updatetime timestamp with time zone
        );

    CREATE INDEX
		idx_clients_premise_name_long
    ON
        clients (premise_name_long);

    CREATE INDEX
        idx_update_pos_premise_code
    ON
        update_pos (premise_code);

    CREATE INDEX
        idx_stock_event_date
    ON
        stock (event_date);
    CREATE INDEX
        idx_stock_premise_code
    ON
        stock (md5(premise_code));
    CREATE INDEX
        idx_stock_quantity
    ON
        stock (quantity);
    CREATE INDEX
        idx_stock_ean
    ON
        stock (md5(ean));
    CREATE INDEX
        idx_stock_sku
    ON
        stock (md5(sku));
    CREATE INDEX
        idx_stock_branch_code
    ON
        stock (md5(branch_code));
    CREATE INDEX
        idx_stock_branch_name
    ON
        stock (md5(branch_name));

    CREATE INDEX
        idx_sales_event_date
    ON
        sales (event_date);
    CREATE INDEX
        idx_sales_premise_code
    ON
        sales (md5(premise_code));
    CREATE INDEX
        idx_sales_quantity
    ON
        sales (quantity);
    CREATE INDEX
        idx_sales_ean
    ON
        sales (md5(ean));
    CREATE INDEX
        idx_sales_sku
    ON
        sales (md5(sku));
    CREATE INDEX
        idx_sales_receipt_id
    ON
        sales (md5(receipt_id));

    CREATE INDEX
        idx_transfers_transfers_type
    ON
        transfers (md5(transfers_type));
    CREATE INDEX
        idx_transfers_event_date
    ON
        transfers (event_date);
    CREATE INDEX
        idx_transfers_premise_code
    ON
        transfers (md5(premise_code));
    CREATE INDEX
        idx_transfers_quantity
    ON
        transfers (quantity);
    CREATE INDEX
        idx_transfers_ean
    ON
        transfers (md5(ean));
    CREATE INDEX
        idx_transfers_sku
    ON
        transfers (md5(sku));
    CREATE INDEX
        idx_transfers_branch_code
    ON
        transfers (md5(branch_code));
    CREATE INDEX
        idx_transfers_branch_name
    ON
        transfers (md5(branch_name));
    CREATE INDEX
        idx_transfers_asn_id
    ON
        transfers (md5(asn_id));

    CREATE INDEX
        idx_tagevent_bizlocation
    ON
        tagevent (md5(bizlocation));
    CREATE INDEX
        idx_tagevent_bizstep
    ON
        tagevent (md5(bizstep));
    CREATE INDEX
        idx_tagevent_biztransList
    ON
        tagevent (biztranslist);
    CREATE INDEX
        idx_tagevent_disposition
    ON
        tagevent (md5(disposition));
    CREATE INDEX
        idx_tagevent_event_action
    ON
        tagevent (md5(event_action));
    CREATE INDEX
        idx_tagevent_event_extension
    ON
        tagevent (event_extension);
    CREATE INDEX
        idx_tagevent_event_id
    ON
        tagevent (md5(event_id));
    CREATE INDEX
        idx_tagevent_event_type
    ON
        tagevent (md5(event_type));
    CREATE INDEX
        idx_tagevent_epcclass
    ON
        tagevent (md5(epcclass));
    CREATE INDEX
        idx_tagevent_eventtime
    ON
        tagevent (eventtime);
    CREATE INDEX
        idx_tagevent_parentid
    ON
        tagevent (md5(parentid));
    CREATE INDEX
        idx_tagevent_premise
    ON
        tagevent (md5(premise));
    CREATE INDEX
        idx_tagevent_quantity
    ON
        tagevent (quantity);
    CREATE INDEX
        idx_tagevent_readpoint
    ON
        tagevent (md5(readpoint));
    CREATE INDEX
        idx_tagevent_recordtime
    ON
        tagevent (recordtime);

    CREATE INDEX
        idx_tagstate_event_action
    ON
        tagstate (md5(event_action));
    CREATE INDEX
        idx_tagstate_bizlocation
    ON
        tagstate (md5(bizlocation));
    CREATE INDEX
        idx_tagstate_bizstep
    ON
        tagstate (md5(bizstep));
    CREATE INDEX
        idx_tagstate_disposition
    ON
        tagstate (md5(disposition));
    CREATE INDEX
        idx_tagstate_epc
    ON
        tagstate (md5(epc));
    CREATE INDEX
        idx_tagstate_eventtime
    ON
        tagstate (eventtime);
    CREATE INDEX
        idx_tagstate_firstseentime
    ON
        tagstate (firstseentime);
    CREATE INDEX
        idx_tagstate_gtin
    ON
        tagstate (md5(gtin));
    CREATE INDEX
        idx_tagstate_manufacturer
    ON
        tagstate (md5(manufacturer));
    CREATE INDEX
        idx_tagstate_manufacturingorder
    ON
        tagstate (md5(manufacturingorder));
    CREATE INDEX
        idx_tagstate_objecttype
    ON
        tagstate (md5(objecttype));
    CREATE INDEX
        idx_tagstate_premise
    ON
        tagstate (md5(premise));
    CREATE INDEX
        idx_tagstate_readpoint
    ON
        tagstate (md5(readpoint));
    CREATE INDEX
        idx_tagstate_recordtime
    ON
        tagstate (recordtime);
    CREATE INDEX
        idx_tagstate_stateparameter
    ON
        tagstate (stateparameter);
    CREATE INDEX
        idx_tagstate_tid
    ON
        tagstate (md5(tid));
    CREATE INDEX
        idx_tagstate_uid
    ON
        tagstate (md5(uid));
    CREATE INDEX
        idx_tagstate_event_id
    ON
        tagstate (md5(event_id));

    CREATE INDEX
        idx_log_tagevent_job_type
    ON
        log_tagevent (md5(job_type));
    CREATE INDEX
        idx_log_tagevent_job_status
    ON
        log_tagevent (md5(job_status));
    CREATE INDEX
        idx_log_tagevent_eventtime_start
    ON
        log_tagevent (eventtime_start);
    CREATE INDEX
        idx_log_tagevent_eventtime_stop
    ON
        log_tagevent (eventtime_stop);
    CREATE INDEX
        idx_log_tagevent_bound_inf
    ON
        log_tagevent (bound_inf);
    CREATE INDEX
        idx_log_tagevent_bound_sup
    ON
        log_tagevent (bound_sup);
    CREATE INDEX
        idx_log_tagevent_page_size
    ON
        log_tagevent (page_size);
    CREATE INDEX
        idx_log_tagevent_fetch_size
    ON
        log_tagevent (fetch_size);
    CREATE INDEX
        idx_log_tagevent_nb_new_doc
    ON
        log_tagevent (nb_new_doc);
    CREATE INDEX
        idx_log_tagevent_total_doc_es
    ON
        log_tagevent (total_doc_es);
    CREATE INDEX
        idx_log_tagevent_total_doc_postgres
    ON
        log_tagevent (total_doc_postgres);
    CREATE INDEX
        idx_log_tagevent_discrepancy
    ON
        log_tagevent (discrepancy);
    CREATE INDEX
        idx_log_tagevent_debug_mode
    ON
        log_tagevent (debug_mode);

    ALTER SCHEMA
        public
    OWNER TO
        admin_db;

    ALTER DATABASE
        ${DATABASE_NAME}
    OWNER TO
        admin_db;

    ALTER TABLE
        calendar
    OWNER TO
        admin_db;
    ALTER TABLE
        log_tagevent
    OWNER TO
        admin_db;
    ALTER TABLE
        sales
    OWNER TO
        admin_db;
    ALTER TABLE
        stock
    OWNER TO
        admin_db;
    ALTER TABLE
        tagevent
    OWNER TO
        admin_db;
    ALTER TABLE
        tagstate
    OWNER TO
        admin_db;
    ALTER TABLE
        transfers
    OWNER TO
        admin_db;
    ALTER TABLE
        clients
    OWNER TO
        admin_db;

    GRANT
        SELECT,
        INSERT,
        UPDATE
    ON
        ALL TABLES
    IN SCHEMA
        public
    TO
        api_user;

    GRANT
        SELECT
    ON
        ALL TABLES
    IN SCHEMA
        public
    TO
        pbi_user;

    ALTER DEFAULT PRIVILEGES
        IN SCHEMA public
        GRANT SELECT, INSERT, UPDATE
        ON TABLES TO api_user;

    ALTER DEFAULT PRIVILEGES
        IN SCHEMA public
        GRANT SELECT
        ON TABLES TO pbi_user;

EOSQL

cat /tmp/postgresql.conf > /var/lib/postgresql/data/postgresql.conf
