-- railway_trains table for storing trains
CREATE TABLE IF NOT EXISTS `railway_trains` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model` varchar(50) NOT NULL,
  `type` varchar(20) NOT NULL,
  `wagons` longtext,
  `stored` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create railway job if it doesn't exist
INSERT IGNORE INTO `jobs` (name, label) VALUES ('railway', 'Railway');

-- Add job grades
INSERT IGNORE INTO `job_grades` (job_name, grade, name, label, salary) VALUES
	('railway', 0, 'recruit', 'Stagiaire', 200),
	('railway', 1, 'metro', 'Conducteur Metro', 400),
	('railway', 2, 'freight', 'Conducteur Fret', 600),
	('railway', 3, 'boss', 'Chef de Gare', 800);