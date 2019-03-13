USE `essentialmode`;

INSERT INTO `items` (`name`, `label`, `limit`, `rare`, `can_remove`) VALUES
	('cannabis', 'Cannabis', 45, 0, 1),
	('marijuana', 'Marijuana', 15, 0, 1),
	('coke', 'Coke leaves', 45, 0, 1),
	('cokebag', 'Bag of Cocaine', 15, 0, 1)

;

INSERT INTO `licenses` (`type`, `label`) VALUES
	('weed_processing', 'Weed Processing License'),
	('coke_processing', 'Cocane Processing License')
;
