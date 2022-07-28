USE testtest22;

-- 1. Select users whose id is either 3,2 or 4

SELECT *
FROM   users
WHERE  id IN ( 3, 2, 4 );

-- 2. Count how many basic and premium listings each active user has
SELECT u.first_name,
       u.last_name,
       Sum(basic)   AS basic,
       Sum(premium) AS premium
FROM   (SELECT userid,
               CASE
                 WHEN status = 2 THEN count
                 ELSE 0
               END AS Basic,
               CASE
                 WHEN status = 3 THEN count
                 ELSE 0
               END AS Premium
        FROM   (SELECT user_id  AS userid,
                       status,
                       Count(*) AS count
                FROM   listings
                WHERE  status IN ( 2, 3 )
                GROUP  BY user_id,
                          status
                ORDER  BY user_id) AS res) b
       INNER JOIN users u
               ON u.id = b.userid
GROUP  BY u.first_name,
          u.last_name;

-- 3. Show the same count as before but only if they have at least ONE premium listing
SELECT u.first_name,
       u.last_name,
       Sum(basic)   AS basic,
       Sum(premium) AS premium
FROM   (SELECT userid,
               CASE
                 WHEN status = 2 THEN count
                 ELSE 0
               END AS Basic,
               CASE
                 WHEN status = 3 THEN count
                 ELSE 0
               END AS Premium
        FROM   (SELECT user_id  AS userid,
                       status,
                       Count(*) AS count
                FROM   listings
                WHERE  status IN ( 2, 3 )
                GROUP  BY user_id,
                          status
                ORDER  BY user_id) AS res) b
       INNER JOIN users u
               ON u.id = b.userid
GROUP  BY u.first_name,
          u.last_name
HAVING Sum(premium) > 0;

-- 4. How much revenue has each active vendor made in 2013
SELECT u.first_name,
       u.last_name,
       c.currency AS currency,
       Sum(price) AS revenue
FROM   clicks c
       INNER JOIN listings l
               ON c.listing_id = l.id
       INNER JOIN users u
               ON u.id = l.user_id
GROUP  BY u.first_name,
          u.last_name,
          c.currency;

-- 5. Insert a new click for listing id 3, at $4.00
INSERT INTO clicks
            (listing_id,
             price,
             currency,
             created)
VALUES      (3,
             4,
             'USD',
             Now());

SELECT Last_insert_id() AS id;

-- 6. Show listings that have not received a click in 2013
SELECT NAME AS listing_name
FROM   listings
WHERE  id NOT IN (SELECT listing_id
                  FROM   clicks
                  WHERE  Year(created) = 2013);

-- 7. For each year show number of listings clicked and number of vendors who owned these listings
SELECT year              AS date,
       Count(listing_id) AS total_listings_clicked,
       Sum(count)        AS total_vendors_affected
FROM   (SELECT Year(created) AS year,
               listing_id,
               Count(*)      AS count
        FROM   clicks c
        GROUP  BY Year(created),
                  listing_id
        ORDER  BY Year(created),
                  listing_id) x
GROUP  BY year;

-- 8. Return a comma separated string of listing names for all active vendors
SELECT u.first_name,
       u.last_name,
       Group_concat(NAME) AS listing_names
FROM   listings l
       INNER JOIN users u
               ON u.id = l.user_id
WHERE  u.status IN ( 2 )
GROUP  BY user_id; 
