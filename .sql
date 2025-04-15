-- 1. Calculate the average price of cars for each model, ordered by average price descending
SELECT
    m.name AS model_name,
    AVG(CAST(c.price AS DECIMAL(10, 2))) AS average_price
        FROM cars c
        JOIN models m ON c.model_id = m.id
        GROUP BY model_name
        ORDER BY average_price DESC;

-- 2. Find the oldest and newest car years for each make
SELECT
    mk.name AS make_name,
    MIN(c.year) AS oldest_year,
    MAX(c.year) AS newest_year
FROM cars c
         JOIN models m ON c.model_id = m.id
         JOIN makes mk ON m.make_id = mk.id
GROUP BY make_name;

-- 3. List models with more than 1 car, along with the count of cars
SELECT
    m.name AS model_name,
    COUNT(c.id) AS car_count
FROM models m
         JOIN cars c ON m.id = c.model_id
GROUP BY model_name
HAVING car_count > 1;

-- 4. List makes that have at least one car with the 'GPS' feature (EXISTS subquery)
SELECT mk.name AS make_name
FROM makes mk
WHERE EXISTS (
    SELECT 1
    FROM models m
             JOIN cars c ON m.id = c.model_id
             JOIN car_features cf ON c.id = cf.car_id
             JOIN features f ON cf.feature_id = f.id
    WHERE m.make_id = mk.id AND f.name = 'GPS'
);

-- 5. Retrieve cars from models that have no features assigned (NOT EXISTS subquery)
SELECT c.*
FROM cars c
WHERE NOT EXISTS (
    SELECT 1
    FROM car_features cf
    WHERE cf.car_id = c.id
);

-- 6. Extract the first 5 characters of each VIN and show them alongside the full VIN
SELECT
    vin,
    LEFT(vin, 5) AS first_five_vin
FROM cars;

-- 7. Find all cars that have both 'GPS' and 'Sunroof' features
SELECT c.*
FROM cars c
WHERE c.id IN (
    SELECT cf.car_id
    FROM car_features cf
             JOIN features f ON cf.feature_id = f.id
    WHERE f.name = 'GPS'
    INTERSECT
    SELECT cf.car_id
    FROM car_features cf
             JOIN features f ON cf.feature_id = f.id
    WHERE f.name = 'Sunroof'
);

-- 8. List makes with the total number of unique features across all their cars
SELECT
    mk.name AS make_name,
    COUNT(DISTINCT cf.feature_id) AS unique_features_count
FROM makes mk
         JOIN models m ON mk.id = m.make_id
         JOIN cars c ON m.id = c.model_id
         JOIN car_features cf ON c.id = cf.car_id
GROUP BY make_name;

-- 9. Retrieve cars that have more than 2 features, along with a concatenated list of feature names
SELECT
    c.id,
    c.vin,
    COUNT(cf.feature_id) AS feature_count,
    GROUP_CONCAT(f.name ORDER BY f.name SEPARATOR ', ') AS features
FROM cars c
         JOIN car_features cf ON c.id = cf.car_id
         JOIN features f ON cf.feature_id = f.id
GROUP BY c.id, c.vin
HAVING feature_count > 2;