CREATE TABLE "member" (
  "id" bigserial,
  "name" varchar(1024) DEFAULT NULL,
  "first_name" varchar(1024) DEFAULT NULL,
  "last_name" varchar(1024) DEFAULT NULL,
  "title" varchar(1024) DEFAULT NULL,
  "url" varchar(4096) NOT NULL,
  "hash" varchar(64) NOT NULL,
  "location" varchar(1024) DEFAULT NULL,
  "industry" varchar(1024) DEFAULT NULL,
  "summary" text,
  "connections" varchar(32) DEFAULT NULL,
  "recommendations_count" varchar(32) DEFAULT NULL,
  "logo_url" text,
  "last_response_code" bigint DEFAULT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "outdated" boolean DEFAULT FALSE,
  "deleted" boolean DEFAULT FALSE,
  "country" varchar(128) DEFAULT NULL,
  "connections_count" bigint DEFAULT NULL,
  "experience_count" bigint DEFAULT NULL,
  "last_updated_ux" bigint DEFAULT NULL,
  "member_shorthand_name" varchar(4096) NOT NULL,
  "member_shorthand_name_hash" varchar(64) NOT NULL,
  "canonical_url" varchar(4096) NOT NULL,
  "canonical_hash" varchar(64) NOT NULL,
  "canonical_shorthand_name" varchar(4096) NOT NULL,
  "canonical_shorthand_name_hash" varchar(64) NOT NULL,
  PRIMARY KEY ("id")
);

-- Create publication for Debezium
CREATE PUBLICATION member_publication FOR TABLE member;

-- Create new table for standardized titles
CREATE TABLE standardized_title (
    "id" SERIAL,
    "job_title" VARCHAR(255),
    "job_function" VARCHAR(255),
    "job_department" VARCHAR(255),
    "job_seniority" VARCHAR(255),
    PRIMARY KEY ("id")
);

-- Create new table for backfill checkpoint
CREATE TABLE backfill_checkpoint (
    "backfill_offset" INTEGER
);

CREATE TABLE "member_also_viewed" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "url" varchar(4096) NOT NULL,
  "title" varchar(1024) DEFAULT NULL,
  "location" varchar(1024) DEFAULT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_awards" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "title" varchar(256) DEFAULT NULL,
  "issuer" varchar(1024) DEFAULT NULL,
  "description" text,
  "date" varchar(128) DEFAULT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_certifications" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "name" varchar(2048) DEFAULT NULL,
  "authority" varchar(2048) DEFAULT NULL,
  "url" varchar(4096) DEFAULT NULL,
  "date_from" varchar(128) DEFAULT NULL,
  "date_to" varchar(128) DEFAULT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_courses" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "position" varchar(512) DEFAULT NULL,
  "courses" text NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON COLUMN member_courses.courses IS 'Semicolon-separated course list';

CREATE TABLE "member_education" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "title" varchar(512) DEFAULT NULL,
  "subtitle" varchar(1024) DEFAULT NULL,
  "date_from" varchar(128) DEFAULT NULL,
  "date_to" varchar(128) DEFAULT NULL,
  "activities_and_societies" text,
  "description" text,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  "school_url" varchar(4096) DEFAULT NULL,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_experience" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "title" varchar(512) DEFAULT NULL,
  "location" varchar(512) DEFAULT NULL,
  "company_name" varchar(2048) DEFAULT NULL,
  "company_url" varchar(4096) DEFAULT NULL,
  "date_from" varchar(128) DEFAULT NULL,
  "date_to" varchar(128) DEFAULT NULL,
  "duration" varchar(128) DEFAULT NULL,
  "description" text,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  "order_in_profile" bigint DEFAULT NULL,
  "company_id" bigint DEFAULT NULL,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_groups" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "name" varchar(512) NOT NULL,
  "url" varchar(4096) NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_interest_list" (
  "id" bigserial,
  "interest" varchar(512) NOT NULL,
  "hash" varchar(64) NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  UNIQUE ("hash")
);

CREATE TABLE "member_interests" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "interest_id" bigint NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY ("interest_id") REFERENCES "member_interest_list" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_language_list" (
  "id" bigserial,
  "language" varchar(512) NOT NULL,
  "hash" varchar(64) NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  UNIQUE ("hash")
);

CREATE TABLE "member_language_proficiency_list" (
  "id" bigserial,
  "proficiency" varchar(512) NOT NULL,
  "hash" varchar(64) NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  UNIQUE ("hash")
);

CREATE TABLE "member_languages" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "language_id" bigint NOT NULL,
  "proficiency_id" bigint DEFAULT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY ("language_id") REFERENCES "member_language_list" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY ("proficiency_id") REFERENCES "member_language_proficiency_list" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_organizations" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "organization" varchar(1024) DEFAULT NULL,
  "position" varchar(1024) DEFAULT NULL,
  "description" text,
  "date_from" varchar(128) DEFAULT NULL,
  "date_to" varchar(128) DEFAULT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_patent_status_list" (
  "id" bigserial,
  "status" varchar(256) NOT NULL,
  "hash" varchar(64) NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  UNIQUE ("hash")
);

CREATE TABLE "member_patents" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "title" varchar(1024) DEFAULT NULL,
  "status_id" bigint DEFAULT NULL,
  "inventors" varchar(2048) DEFAULT NULL,
  "date" varchar(128) DEFAULT NULL,
  "url" varchar(4096) DEFAULT NULL,
  "description" text,
  "valid_area" varchar(256) DEFAULT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY ("status_id") REFERENCES "member_patent_status_list" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_posts_see_more_urls" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "url" varchar(4096) NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_projects" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "name" varchar(512) DEFAULT NULL,
  "url" varchar(4096) DEFAULT NULL,
  "description" text,
  "date_from" varchar(128) DEFAULT NULL,
  "date_to" varchar(128) DEFAULT NULL,
  "team_members" text,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_publications" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "title" varchar(2048) DEFAULT NULL,
  "publisher" varchar(1024) DEFAULT NULL,
  "date" varchar(128) DEFAULT NULL,
  "description" text,
  "authors" varchar(4096) DEFAULT NULL,
  "url" varchar(4096) DEFAULT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_recommendations" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "recommendation" text NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_skill_list" (
  "id" bigserial,
  "skill" varchar(512) NOT NULL,
  "hash" varchar(64) NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  UNIQUE ("hash")
);

CREATE TABLE "member_skills" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "skill_id" bigint NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY ("skill_id") REFERENCES "member_skill_list" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_test_scores" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "name" varchar(1024) DEFAULT NULL,
  "date" varchar(128) DEFAULT NULL,
  "description" text,
  "score" varchar(1024) DEFAULT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_volunteering_care_list" (
  "id" bigserial,
  "care" varchar(512) NOT NULL,
  "hash" varchar(64) NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  UNIQUE ("hash")
);

CREATE TABLE "member_volunteering_cares" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "care_id" bigint NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("care_id") REFERENCES "member_volunteering_care_list" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_volunteering_opportunity_list" (
  "id" bigserial,
  "opportunity" varchar(512) NOT NULL,
  "hash" varchar(64) NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  UNIQUE ("hash")
);

CREATE TABLE "member_volunteering_opportunities" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "opportunity_id" bigint NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY ("opportunity_id") REFERENCES "member_volunteering_opportunity_list" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_volunteering_positions_cause_list" (
  "id" bigserial,
  "cause" varchar(512) NOT NULL,
  "hash" varchar(64) NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  UNIQUE ("hash")
);

CREATE TABLE "member_volunteering_positions" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "organization" varchar(2048) DEFAULT NULL,
  "role" varchar(1024) DEFAULT NULL,
  "cause_id" bigint DEFAULT NULL,
  "date_from" varchar(128) DEFAULT NULL,
  "date_to" varchar(128) DEFAULT NULL,
  "duration" varchar(128) DEFAULT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  "description" text,
  "organization_url" varchar(4096) DEFAULT NULL,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY ("cause_id") REFERENCES "member_volunteering_positions_cause_list" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_volunteering_support_list" (
  "id" bigserial,
  "support" varchar(512) NOT NULL,
  "hash" varchar(64) NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  UNIQUE ("hash")
);

CREATE TABLE "member_volunteering_supports" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "support_id" bigint NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY ("support_id") REFERENCES "member_volunteering_support_list" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_websites" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "website" varchar(4096) NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_similar_profiles" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "url" varchar(4096) NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_courses_suggestion_list" (
  "id" bigserial,
  "name" varchar(4096) NOT NULL,
  "hash" varchar(64) NOT NULL,
  "url" varchar(4096) NOT NULL,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE ("hash"),
  PRIMARY KEY ("id")
);

CREATE TABLE "member_courses_suggestion" (
  "id" bigserial,
  "member_id" bigint NOT NULL,
  "course_suggestion_id" bigint,
  "created" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY ("course_suggestion_id") REFERENCES "member_courses_suggestion_list"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "member_hidden_status" (
  "id" bigserial,
  "member_id" BIGINT NOT NULL,
  "is_hidden" boolean DEFAULT FALSE,
  "created" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_updated" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted" boolean DEFAULT FALSE,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE OR REPLACE FUNCTION u (txt text)
RETURNS text AS
$$
BEGIN
   txt = REPLACE(txt, '\\r', E'\r');
   txt = REPLACE(txt, '\\n', E'\n');
   txt = REPLACE(txt, '""', '"');
   RETURN txt;
END
$$ LANGUAGE plpgsql;