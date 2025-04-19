LOAD DATA LOCAL INFILE
'%FILENAME%'
INTO TABLE member
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 0 LINES
(
  @`id`,
  @`name`,
  @`first_name`,
  @`last_name`,
  @`title`,
  @`url`,
  @`hash`,
  @`location`,
  @`industry`,
  @`summary`,
  @`connections`,
  @`recommendations_count`,
  @`logo_url`,
  @`last_response_code`,
  @`created`,
  @`last_updated`,
  @`outdated`,
  @`deleted`,
  @`country`,
  @`connections_count`,
  @`experience_count`,
  @`last_updated_ux`,
  @`member_shorthand_name`,
  @`member_shorthand_name_hash`,
  @`canonical_url`,
  @`canonical_hash`,
  @`canonical_shorthand_name`,
  @`canonical_shorthand_name_hash`
)
SET
  `id` = u(@`id`),
  `name` = u(@`name`),
  `first_name` = u(@`first_name`),
  `last_name` = u(@`last_name`),
  `title` = u(@`title`),
  `url` = u(@`url`),
  `hash` = u(@`hash`),
  `location` = u(@`location`),
  `industry` = u(@`industry`),
  `summary` = u(@`summary`),
  `connections` = u(@`connections`),
  `recommendations_count` = u(@`recommendations_count`),
  `logo_url` = u(@`logo_url`),
  `last_response_code` = u(@`last_response_code`),
  `created` = u(@`created`),
  `last_updated` = u(@`last_updated`),
  `outdated` = u(@`outdated`),
  `deleted` = u(@`deleted`),
  `country` = u(@`country`),
  `connections_count` = u(@`connections_count`),
  `experience_count` = u(@`experience_count`),
  `last_updated_ux` = u(@`last_updated_ux`),
  `member_shorthand_name` = u(@`member_shorthand_name`),
  `member_shorthand_name_hash` = u(@`member_shorthand_name_hash`),
  `canonical_url` = u(@`canonical_url`),
  `canonical_hash` = u(@`canonical_hash`),
  `canonical_shorthand_name` = u(@`canonical_shorthand_name`),
  `canonical_shorthand_name_hash` = u(@`canonical_shorthand_name_hash`);