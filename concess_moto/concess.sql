--
-- Structure de la table `society_vehicles`
--

CREATE TABLE `society_vehicles` (
  `society` varchar(40) NOT NULL,
  `plate` varchar(12) NOT NULL,
  `vehicle` longtext DEFAULT NULL,
  `stored` tinyint(4) NOT NULL DEFAULT 0,
  `label` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Index pour la table `society_vehicles`
--
ALTER TABLE `society_vehicles`
  ADD PRIMARY KEY (`plate`);
COMMIT;

CREATE TABLE `vehicle_categories` (
  `name` varchar(60) NOT NULL,
  `label` varchar(60) NOT NULL,
  `image` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `vehicles` (
  `name` varchar(60) NOT NULL,
  `model` varchar(60) NOT NULL,
  `price` int(11) NOT NULL,
  `category` varchar(60) DEFAULT NULL,
  `stock` int(255) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`model`);
COMMIT;

CREATE TABLE `historique_concessionnaire` (
  `type` varchar(60) NOT NULL,
  `gain` varchar(100) NOT NULL,
  `identifier` varchar(255) NOT NULL,
  `id` int(11) NOT NULL,
  `cost` varchar(11) DEFAULT NULL,
  `date` varchar(255) DEFAULT NULL,
  `vehicle` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `historique_concessionnaire`
  ADD PRIMARY KEY (`id`);
COMMIT;

ALTER TABLE `historique_concessionnaire`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=80;
COMMIT;


CREATE TABLE `automatisation` (
  `society` varchar(60) NOT NULL,
  `statut` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO `automatisation` (`society`, `statut`) VALUES
('concess', 'Non-automatique');

ALTER TABLE `automatisation`
  ADD UNIQUE KEY `society` (`society`);
COMMIT;

INSERT INTO `jobs` (`name`, `label`) VALUES
('concess', 'Concessionnaire');

INSERT INTO `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
(7, 'concess', 1, 'employed', 'Employé', 3500, '{}', '{}'),
(8, 'concess', 2, 'avanced', 'Vendeur', 2000, '{}', '{}'),
(9, 'concess', 3, 'leader', 'Chef Equipe', 2500, '', ''),
(10, 'concess', 4, 'boss', 'Patron', 5000, '', '');

INSERT INTO `addon_account` (`name`, `label`, `shared`) VALUES
('society_concess', 'Concessionnaire', 2);

INSERT INTO `addon_account_data` (`id`, `account_name`, `money`, `owner`) VALUES
(2, 'society_concess', 0, NULL); 