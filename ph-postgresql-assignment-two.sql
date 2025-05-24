-- Active: 1747486928827@@127.0.0.1@5432@conservation_db


-- 1. create table for rangers
CREATE TABLE rangers (
    ranger_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    region VARCHAR(100)
);



-- 2. create table for species
CREATE TABLE species (
    species_id SERIAL PRIMARY KEY,
    common_name VARCHAR(100),
    scientific_name VARCHAR(150),
    discovery_date DATE,
    conservation_status VARCHAR(50)
);


-- 3. create table for sightings
CREATE TABLE sightings (
    sightings_id SERIAL PRIMARY KEY,
    ranger_id INTEGER NOT NULL,
    species_id INTEGER NOT NULL,
    scientific_name VARCHAR(150),
    sighting_time TIMESTAMP NOT NULL,
    location VARCHAR(150) NOT NULL,
    notes TEXT,
    FOREIGN KEY (ranger_id) REFERENCES rangers(ranger_id),
    FOREIGN KEY (species_id) REFERENCES species(species_id)
);



-- 4. insert data into rangers table
INSERT INTO rangers (name, region) VALUES ('Alice Green', 'Northern Hills'), ('Bob White', 'River Delta'),('Carol King', 'Mountain Range');


-- inserting data into species
INSERT INTO species(common_name, scientific_name, discovery_date, conservation_status)  values
('Snow Leopard', 'Panthera uncia', '1775-01-01', 'Endangered'),
('Bengal Tiger', 'Panthera tigris tigris', '1758-01-01', 'Endangered'),
('Red Panda', 'Ailurus fulgens', '1825-01-01', 'Vulnerable'),
('Asiatic Elephant', 'Elephas maximus indicus', '1758-01-01', 'Endangered');



-- inserting data into sightings
INSERT INTO sightings(species_id, ranger_id, location, sighting_time, notes) VALUES
(1, 1, 'Peak Ridge', '2024-05-10 07:45:00', 'Camera trap image captured'),
(2, 2, 'Bankwood Area', '2024-05-12 16:20:00', 'Juvenile seen'),
(3, 3, 'Bamboo Grove Eastx', '2024-05-15 09:10:00', 'Feeding observed'),
(1, 2, 'Snowfall Pass', '2024-05-18 18:30:00', NULL)



-- 1️⃣ Register a new ranger with provided data with name = 'Derek Fox' and region = 'Coastal Plains'
INSERT INTO rangers(name, region) VALUES ('Derek Fox', 'Coastal Plains')




-- 2️⃣ Count unique species ever sighted.
SELECT COUNT(DISTINCT species_id) AS unique_species_count FROM sightings;


-- 3️⃣ Find all sightings where the location includes "Pass".
SELECT * FROM sightings
    WHERE location ILIKE('%Pass%');


-- 4️⃣ List each ranger's name and their total number of sightings.
SELECT r.name, COUNT(sightings_id) AS total_sightings from rangers AS r
    JOIN sightings AS s ON r.ranger_id = s.ranger_id
    GROUP BY r.name ORDER BY r.name ASC;



-- 5️⃣ List species that have never been sighted.
SELECT common_name from species
    WHERE species_id NOT IN ( SELECT DISTINCT species_id from sightings);





-- 6️⃣ Show the most recent 2 sightings.
SELECT sp.common_name, sg.sighting_time, rg.name FROM sightings AS sg
    INNER JOIN rangers AS rg ON sg.ranger_id = rg.ranger_id
    INNER JOIN species AS sp ON sg.species_id = sp.species_id
    ORDER BY sighting_time DESC
    LIMIT 2





7️⃣ Update all species discovered before year 1800 to have status 'Historic'.
UPDATE species
    set conservation_status = 'Historic'
    WHERE discovery_date < '1800-01-01'





CREATE OR REPLACE FUNCTION get_time_0f_day(ts TIMESTAMP) 
RETURNS TEXT
LANGUAGE PLpgsql

AS

$$
    BEGIN
        IF EXTRACT(hour from ts) < 12 THEN
            RETURN 'Morning';
        ELSEIF EXTRACT(hour from ts) BETWEEN 12 AND 17 THEN
            RETURN 'Afternoon';
        ELSE
            RETURN 'Evening';
        END IF;
    END;
$$;




-- 8️⃣ Label each sighting's time of day as 'Morning', 'Afternoon', or 'Evening'.
SELECT sightings_id, get_time_0f_day(sighting_time) FROM sightings;



-- 9️⃣ Delete rangers who have never sighted any species

DELETE FROM rangers
    WHERE ranger_id NOT IN ( SELECT ranger_id from sightings);
