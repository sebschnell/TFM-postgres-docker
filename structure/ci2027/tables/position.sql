SET search_path TO private_ci2027_001, public;


CREATE TABLE position (
    id SERIAL PRIMARY KEY,
    plot_id SERIAL NOT NULL,
	plot_location_id SERIAL NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	modified_at TIMESTAMP DEFAULT NULL,
    modified_by REGROLE DEFAULT CURRENT_USER::REGROLE,

	interval_name enum_interval_name NOT NULL DEFAULT 'ci2027', -- Intervall

    geometry_median GEOMETRY(Point, 4326),
	geometry_mean GEOMETRY(Point, 4326),

	--longitude_median float NULL, -- LON_MED
	--longitude_mean float NULL, -- LON_MEAN
--
	--latitude_median float NULL, -- LAT_MED
	--latitude_mean float NULL, -- LAT_MEAN

	altitude_median float NULL, -- NEU
	altitude_mean float NULL, -- Hoehe_MEAN
	
	hdop_mean float NULL, -- HDOP  MEAN OR MEDIAN ???
	pdop_mean float NULL, -- PDOP  MEAN OR MEDIAN ???

	satellites_count_mean float NULL, -- NumSat MEAN OR MEDIAN ???

	measurement_count smallint NULL, -- AnzahlMessungen
	
	rtcm_age float NULL, -- RTCMAlter

	start_measurement timestamp NULL, -- UTCStartzeit
	stop_measurement timestamp NULL, -- UTCStopzeit

	device_gps varchar(150) NULL, -- Geraet (smallint) || Ist hier ein freies Eingabefeld nicht sinnvoller ???

	quality enum_gnss_quality NULL -- GNSS_Qualitaet

);

COMMENT ON TABLE position IS 'Position der Probenfläche';
COMMENT ON COLUMN position.id IS 'Unique ID der Probenfläche';
COMMENT ON COLUMN position.plot_id IS 'ID der Probenfläche';
COMMENT ON COLUMN position.created_at IS 'Erstellungszeitpunkt';
COMMENT ON COLUMN position.longitude_median IS 'Longitude Median';
COMMENT ON COLUMN position.longitude_mean IS 'Longitude Mean';
COMMENT ON COLUMN position.latitude_median IS 'Latitude Median';
COMMENT ON COLUMN position.latitude_mean IS 'Latitude Mean';
COMMENT ON COLUMN position.altitude_median IS 'Altitude Median';
COMMENT ON COLUMN position.altitude_mean IS 'Altitude Mean';
COMMENT ON COLUMN position.hdop_mean IS 'HDOP Mean';
COMMENT ON COLUMN position.pdop_mean IS 'PDOP Mean';
COMMENT ON COLUMN position.satellites_count_mean IS 'Satellites Count Mean';
COMMENT ON COLUMN position.measurement_count IS 'Measurement Count';
COMMENT ON COLUMN position.rtcm_age IS 'RTCM Age';
COMMENT ON COLUMN position.start_measurement IS 'Start Measurement';
COMMENT ON COLUMN position.stop_measurement IS 'Stop Measurement';
COMMENT ON COLUMN position.device_gps IS 'Device GPS';
COMMENT ON COLUMN position.quality IS 'Quality of GNSS';

ALTER TABLE position ADD CONSTRAINT FK_Position_Plot FOREIGN KEY (plot_id)
	REFERENCES plot (id)
	ON DELETE CASCADE;

ALTER TABLE position ADD CONSTRAINT CK_Position_Geometry CHECK (ST_IsValid(geometry));
--CREATE INDEX idx_position_geometry ON position USING GIST (geometry);

ALTER TABLE position ADD CONSTRAINT FK_Position_LookupGnssQuality FOREIGN KEY (quality)
	REFERENCES lookup_gnss_quality (abbreviation);
