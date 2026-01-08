/*View: Citations by Zip Code*/
DROP VIEW IF EXISTS citations_by_zip_code;

CREATE VIEW citations_by_zip_code AS
SELECT locations.zip_code, COUNT(citations.citation_id) AS amount_of_citations
FROM citations
JOIN vehicle_locations ON citations.citation_id = vehicle_locations.citation_id
JOIN locations ON vehicle_locations.location_id = locations.location_id
WHERE locations.zip_code IS NOT NULL AND locations.zip_code != ""
GROUP BY locations.zip_code
HAVING COUNT(citations.citation_id) >= 20
ORDER BY COUNT(citations.citation_id) ASC;

SELECT * FROM citations_by_zip_code;
/*This shows the amount of citations by zip code for zip codes that have at least 20 citations  */

/*---------------------------------------------------------------------------------------------------------------------------------*/

/*View: Summary of Officer Citations*/
DROP VIEW IF EXISTS summary_of_officer_citations;

CREATE VIEW summary_of_officer_citations AS
SELECT officers.officer_id, officers.officer, COUNT(citations.citation_id) AS amount_of_citations
FROM citations
JOIN officers ON citations.officer_id = officers.officer_id
GROUP BY officers.officer_id, officers.officer
HAVING COUNT(citations.citation_id) >= 30
ORDER BY COUNT(citations.citation_id) ASC;

SELECT * FROM summary_of_officer_citations;
/*This shows officers that have issued at least 30 citations*/

/*---------------------------------------------------------------------------------------------------------------------------------*/

/*View: Summary of Citations by Notice Levels */
DROP VIEW IF EXISTS citations_by_notice_level;

CREATE VIEW citations_by_notice_level AS
SELECT notice_levels.notice_level, COUNT(citations.citation_id) AS amount_of_citations
FROM citations
JOIN notice_levels ON citations.notice_level_id = notice_levels.notice_level_id
WHERE citations.notice_level_id IS NOT NULL AND citations.notice_level_id != 6
GROUP BY notice_levels.notice_level
ORDER BY COUNT(citations.citation_id) ASC;

SELECT * FROM citations_by_notice_level;
/* This groups citations based on all citation levels and gives their amounts*/

/*----------------------------------------------------------------------------------------------------------------------------------*/

/*View: Accumulated Fines For All Types of Violations*/
DROP VIEW IF EXISTS violations_vs_fine_details;

CREATE VIEW violations_vs_fine_details AS
SELECT violations.violation_id, violations.violation_code, violations.violation_description,
    SUM(fine_level_1.fine_level1_amount + fine_level_2.fine_level2_amount) AS total_fine
FROM citations
JOIN violations ON citations.violation_id = violations.violation_id
JOIN fine_level_1 ON citations.fine_level1_id = fine_level_1.fine_level1_id
JOIN fine_level_2 ON citations.fine_level2_id = fine_level_2.fine_level2_id
GROUP BY violations.violation_id, violations.violation_code, violations.violation_description
ORDER BY total_fine ASC;

SELECT * FROM violations_vs_fine_details;
/*This adds up the total fines of both levels for the different types of violations*/

/*----------------------------------------------------------------------------------------------------------------------------------*/

/*Procedure: Get Citations by a Specific Violation ID*/
DELIMITER //

DROP PROCEDURE IF EXISTS get_citations_by_violation //

CREATE PROCEDURE get_citations_by_violation(IN violation_id_input INT)
BEGIN
    SELECT citations.citation_id, citations.ticket_number, violations.violation_code, 
    violations.violation_description, citations.notice_number
    FROM citations
    JOIN violations ON citations.violation_id = violations.violation_id
    WHERE citations.violation_id = violation_id_input;
END //

DELIMITER ;

/*Call the procedure and enter a Violation ID number*/
CALL get_citations_by_violation(10);

/*This procedure allows users to be able to enter a violation number 
and receive citations associated with that violation code*/

/*----------------------------------------------------------------------------------------------------------------------------------*/

/*Procedure: Get Citations by the Vehicle Make*/
DELIMITER //

DROP PROCEDURE IF EXISTS get_citations_by_vehicle_make //

CREATE PROCEDURE get_citations_by_vehicle_make(IN vehicle_make_input VARCHAR(50))
BEGIN
    SELECT 
        citations.citation_id, citations.ticket_number, vehicle_locations.issue_date,
        vehicles.vehicle_make, locations.violation_location
    FROM citations
    JOIN vehicle_locations ON citations.citation_id = vehicle_locations.citation_id
    JOIN vehicles ON vehicle_locations.vehicle_id = vehicles.vehicle_id
    JOIN locations ON vehicle_locations.location_id = locations.location_id
    WHERE vehicles.vehicle_make = vehicle_make_input;
END //

DELIMITER ;

CALL get_citations_by_vehicle_make('TOYT');

/*This procedure allows users to be able to enter the vehicle make and 
receive citations with that make only*/

/*----------------------------------------------------------------------------------------------------------------------------------*/

/*Function: Description of Violations*/
DELIMITER $$

DROP FUNCTION IF EXISTS violation_description_info$$

CREATE FUNCTION violation_description_info(violation_id INT)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE violation_description VARCHAR(100);
    SELECT violations.violation_description INTO violation_description
    FROM violations
    WHERE violations.violation_id = violation_id;
    RETURN violation_description;
END$$

DELIMITER ;

/*Enter the violation id to get the description associated with it*/
SELECT violation_description_info(1);

/*This function gives the violation description of a given violation ID*/

/*----------------------------------------------------------------------------------------------------------------------------------*/

/*Function: Violation Amount by Vehicle Make*/
DELIMITER $$

DROP FUNCTION IF EXISTS get_violation_amount_by_make$$

CREATE FUNCTION get_violation_amount_by_make(vehicle_make_input VARCHAR(100))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE citation_amount INT;
    SELECT COUNT(citations.citation_id) 
    INTO citation_amount
    FROM citations
    JOIN vehicle_locations ON citations.citation_id = vehicle_locations.citation_id
    JOIN vehicles ON vehicle_locations.vehicle_id = vehicles.vehicle_id
    WHERE vehicles.vehicle_make = vehicle_make_input;
    RETURN citation_amount;
END$$

DELIMITER ;

/*Enter the vehicle make*/
SELECT get_violation_amount_by_make('CHEV');

/*This Function counts the number of citations issued for a given vehicle make.*/
