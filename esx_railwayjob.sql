USE `es_extended`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_railway', 'Railway', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_railway', 'Railway', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_railway', 'Railway', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('railway', 'Railway')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('railway', 0, 'recruit', 'Stagiaire', 200, '{}', '{}'),
	('railway', 1, 'metro', 'Conducteur Metro', 400, '{}', '{}'),
	('railway', 2, 'freight', 'Conducteur Fret', 600, '{}', '{}'),
	('railway', 3, 'boss', 'Chef de Gare', 800, '{}', '{}')
;

CREATE TABLE IF NOT EXISTS `railway_trains` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vehicle` varchar(255) NOT NULL,
  `type` varchar(20) NOT NULL,
  `stored` int(11) NOT NULL DEFAULT 0,
  `plate` varchar(12) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `railway_routes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `type` varchar(20) NOT NULL,
  `start_station` varchar(50) NOT NULL,
  `end_station` varchar(50) NOT NULL,
  `stops` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Routes par défaut
INSERT INTO `railway_routes` (name, type, start_station, end_station, stops) VALUES
	('Metro Line 1', 'metro', 'Central Station', 'South Station', '["Downtown Station"]'),
	('Freight Route 1', 'freight', 'Freight Terminal', 'Mountain Depot', '["Industrial Zone"]')
;