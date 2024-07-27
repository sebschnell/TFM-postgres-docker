SET search_path TO private_ci2027_001, public;

-- Function to import sapling_1m
CREATE OR REPLACE FUNCTION set_sapling_1m(parent_id int, json_object json, plot_location_id int)
RETURNS json AS
$$
DECLARE
    child_object json;

    modified jsonb := '[]'::jsonb;
    modified_element jsonb;

    changed_values RECORD;
BEGIN
    
    IF json_object IS NULL THEN
        RETURN modified;
    END IF;

    CREATE TEMP TABLE IF NOT EXISTS temp_child_ids (id INT);
    TRUNCATE temp_child_ids;

    FOR child_object IN SELECT * FROM json_array_elements(json_object)
    LOOP

        INSERT INTO sapling_1m (id, plot_id, plot_location_id)
        VALUES (
            COALESCE(NULLIF((child_object->>'id')::text, 'null')::int, nextval('sapling_1m_id_seq')),
            parent_id,
            plot_location_id
            
        )
        ON CONFLICT (id) DO UPDATE
        SET
            plot_id = EXCLUDED.plot_id,
            plot_location_id = EXCLUDED.plot_location_id
            
        WHERE sapling_1m.id = EXCLUDED.id AND sapling_1m.plot_id = parent_id
        RETURNING * INTO changed_values;

        INSERT INTO temp_child_ids (id) VALUES (changed_values.id);

        modified_element := row_to_json(changed_values);

        modified := modified || modified_element;

    END LOOP;

    DELETE FROM sapling_1m WHERE id NOT IN (SELECT id FROM temp_child_ids) AND sapling_1m.plot_id = parent_id;

RETURN modified;
END;
$$ LANGUAGE plpgsql;