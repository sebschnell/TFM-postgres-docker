SET search_path TO private_ci2027_001, public;

GRANT usage ON SCHEMA private_ci2027_001 TO web_anon;

CREATE OR REPLACE FUNCTION export_geojson(cluster_ids int[])
RETURNS json AS
$$
DECLARE
BEGIN
    
        RETURN (
            SELECT COALESCE(json_agg(
                json_build_object(
                    'cluster', cluster.*,
                    'plots', (SELECT json_agg(
                            json_build_object(
                                'plot', plot.*,
                                'wzp_tree', (
                                    json_build_object(
                                        'wzp_tree', (
                                            SELECT json_agg(row_to_json(wzp_tree))
                                            FROM wzp_tree WHERE wzp_tree.plot_id = plot.id
                                        ),
                                        'plot_location', (
                                            SELECT row_to_json(plot_location)
                                            FROM plot_location WHERE plot_location.plot_id = plot.id AND plot_location.parent_table = 'wzp_tree'
                                        )
                                    ) 
                                ),
                                'deadwood', (
                                    json_build_object(
                                        'deadwood', (
                                            SELECT json_agg(row_to_json(deadwood))
                                            FROM deadwood WHERE deadwood.plot_id = plot.id
                                        ),
                                        'plot_location', (
                                            SELECT row_to_json(plot_location)
                                            FROM plot_location WHERE plot_location.plot_id = plot.id AND plot_location.parent_table = 'deadwood'
                                        )
                                    )
                                ),
                                'edges', (
                                    json_build_object(
                                        'edges', (
                                            SELECT json_agg(row_to_json(edges))
                                            FROM edges WHERE edges.plot_id = plot.id
                                        ),
                                        'plot_location', (
                                            SELECT row_to_json(plot_location)
                                            FROM plot_location WHERE plot_location.plot_id = plot.id AND plot_location.parent_table = 'edge'
                                        )
                                    )
                                ),
                                'position', (
                                    json_build_object(
                                        'position', (
                                            SELECT json_agg(row_to_json(position))
                                            FROM position WHERE position.plot_id = plot.id
                                        ),
                                        'plot_location', (
                                            SELECT row_to_json(plot_location)
                                            FROM plot_location WHERE plot_location.plot_id = plot.id AND plot_location.parent_table = 'position'
                                        )
                                    )
                                ),
                                'sapling_1m', (
                                    json_build_object(
                                        'sapling_1m', (
                                            SELECT json_agg(row_to_json(sapling_1m))
                                            FROM sapling_1m WHERE sapling_1m.plot_id = plot.id
                                        ),
                                        'plot_location', (
                                            SELECT row_to_json(plot_location)
                                            FROM plot_location WHERE plot_location.plot_id = plot.id AND plot_location.parent_table = 'sapling_1m'
                                        )
                                    )
                                ),
                                'sapling_2m', (
                                    json_build_object(
                                        'sapling_2m', (
                                            SELECT json_agg(row_to_json(sapling_2m))
                                            FROM sapling_2m WHERE sapling_2m.plot_id = plot.id
                                        ),
                                        'plot_location', (
                                            SELECT row_to_json(plot_location)
                                            FROM plot_location WHERE plot_location.plot_id = plot.id AND plot_location.parent_table = 'sapling_2m'
                                        )
                                    )
                                )
                            )
                        )
                        FROM plot WHERE plot.cluster_id = cluster.id
                    )
                )
            ) , '[]'::json)
            FROM cluster 
            WHERE cluster.id = ANY(cluster_ids) OR array_length(cluster_ids, 1) IS NULL
            
        );
END;
$$ LANGUAGE plpgsql;

ALTER FUNCTION export_geojson(int[]) OWNER TO postgres;
GRANT EXECUTE ON FUNCTION export_geojson(int[]) TO web_anon;

