/*
    Script:   Extract Senior Results (aggregated)
    Created:  2019-07-06
    Author:   Michael George / 2015GEOR02

    Purpose:  Simple extract to facilitate the production of "Indicative Senior Rankings".
              https://logiqx.github.io/wca-ipy/Indicative_Rankings.html

    Notes:    The extracts do not disclose any WCA IDs, only counts of senior competitors.
              All consolidated results are modified using truncation / reduction of precision.
              Variable reduction of precision is achieved through the use of bit masking.

              Each event has been assigned a unique profile for the bit masking. For example:
                - 3x3x3 and Pyraminx have a maximum precision of 8 (0.08s)
                - 4x4x4 and Clock have a maximum precision of 64 (0.64s)
                - 5x5x5 and Square-1 have a maximum precision of 128 (1.28s)
                - Feet and 7x7x7 have a maximum precision of 1024 (10.24s)
                - 4BLD, 5BLD and MultiBLD have the largest bit masks (several minutes)
              Faster / slower results have more bits masked, further reducing the precision.

              The event profiles have been generated from statistical models created from WCA results.
              The average group size (across the entire WCA community) is typically 150-250 persons.
              The minimum group size (across the entire WCA community) is intended to be 100 persons.
              The only exception to this rule is 5BLD (mean of 3) which only has 44 people in the WCA.
*/

SET @max_shift = 31;

/*
   Extract AGGREGATED senior results (averages)
*/

SELECT eventId, age_category, modified_average, mask, COUNT(*) AS num_persons
FROM
(
  SELECT personId, eventId, age_category,
    @shift :=
    (
      CASE
        WHEN eventId = '333' THEN
        (
          CASE
            WHEN best < 768 THEN 10
            WHEN best < 832 THEN 6
            WHEN best < 896 THEN 5
            WHEN best < 1024 THEN 4
            WHEN best < 3968 THEN 3
            WHEN best < 5952 THEN 4
            WHEN best < 7488 THEN 5
            WHEN best < 9088 THEN 6
            WHEN best < 10752 THEN 7
            WHEN best < 12800 THEN 8
            WHEN best < 14336 THEN 9
            WHEN best < 16384 THEN 10
            WHEN best < 20480 THEN 11
            WHEN best < 24576 THEN 12
            ELSE @max_shift
          END
        )
        WHEN eventId = '222' THEN
        (
          CASE
            WHEN best < 224 THEN 8
            WHEN best < 272 THEN 4
            WHEN best < 344 THEN 3
            WHEN best < 1200 THEN 2
            WHEN best < 1664 THEN 3
            WHEN best < 2112 THEN 4
            WHEN best < 2560 THEN 5
            WHEN best < 3072 THEN 6
            WHEN best < 3584 THEN 7
            WHEN best < 4096 THEN 8
            WHEN best < 5632 THEN 9
            ELSE @max_shift
          END
        )
        WHEN eventId = '444' THEN
        (
          CASE
            WHEN best < 3328 THEN 12
            WHEN best < 3584 THEN 8
            WHEN best < 3840 THEN 7
            WHEN best < 9344 THEN 6
            WHEN best < 11776 THEN 7
            WHEN best < 13824 THEN 8
            WHEN best < 16384 THEN 9
            WHEN best < 18432 THEN 10
            WHEN best < 20480 THEN 11
            WHEN best < 24576 THEN 12
            ELSE @max_shift
          END
        )
        WHEN eventId = '555' THEN
        (
          CASE
            WHEN best < 6400 THEN 13
            WHEN best < 7424 THEN 8
            WHEN best < 14336 THEN 7
            WHEN best < 16896 THEN 8
            WHEN best < 20480 THEN 9
            WHEN best < 22528 THEN 10
            WHEN best < 24576 THEN 11
            WHEN best < 32768 THEN 12
            ELSE @max_shift
          END
        )
        WHEN eventId = '666' THEN
        (
          CASE
            WHEN best < 12288 THEN 14
            WHEN best < 14336 THEN 10
            WHEN best < 24576 THEN 9
            WHEN best < 28672 THEN 10
            WHEN best < 32768 THEN 11
            WHEN best < 40960 THEN 13
            ELSE @max_shift
          END
        )
        WHEN eventId = '777' THEN
        (
          CASE
            WHEN best < 18432 THEN 15
            WHEN best < 20480 THEN 11
            WHEN best < 38912 THEN 10
            WHEN best < 45056 THEN 11
            WHEN best < 49152 THEN 12
            ELSE @max_shift
          END
        )
        WHEN eventId = '333bf' THEN
        (
          CASE
            WHEN best < 4096 THEN 12
            WHEN best < 20480 THEN 11
            WHEN best < 24576 THEN 12
            ELSE @max_shift
          END
        )
        WHEN eventId = '333fm' THEN
        (
          CASE
            WHEN best < 3072 THEN 12
            WHEN best < 3328 THEN 8
            WHEN best < 4608 THEN 7
            WHEN best < 5120 THEN 8
            WHEN best < 5632 THEN 9
            ELSE @max_shift
          END
        )
        WHEN eventId = '333oh' THEN
        (
          CASE
            WHEN best < 1408 THEN 11
            WHEN best < 1664 THEN 6
            WHEN best < 4736 THEN 5
            WHEN best < 5888 THEN 6
            WHEN best < 6144 THEN 7
            WHEN best < 8704 THEN 8
            WHEN best < 10240 THEN 9
            WHEN best < 12288 THEN 11
            WHEN best < 16384 THEN 12
            ELSE @max_shift
          END
        )
        WHEN eventId = '333ft' THEN
        (
          CASE
            WHEN best < 6144 THEN 13
            WHEN best < 8192 THEN 11
            WHEN best < 14336 THEN 10
            WHEN best < 20480 THEN 11
            WHEN best < 24576 THEN 12
            ELSE @max_shift
          END
        )
        WHEN eventId = 'clock' THEN
        (
          CASE
            WHEN best < 768 THEN 10
            WHEN best < 896 THEN 7
            WHEN best < 1920 THEN 6
            WHEN best < 3328 THEN 7
            WHEN best < 3584 THEN 8
            WHEN best < 5120 THEN 9
            WHEN best < 6144 THEN 10
            ELSE @max_shift
          END
        )
        WHEN eventId = 'minx' THEN
        (
          CASE
            WHEN best < 5120 THEN 13
            WHEN best < 6144 THEN 9
            WHEN best < 15360 THEN 8
            WHEN best < 18432 THEN 9
            WHEN best < 22528 THEN 10
            WHEN best < 24576 THEN 11
            WHEN best < 32768 THEN 12
            ELSE @max_shift
          END
        )
        WHEN eventId = 'pyram' THEN
        (
          CASE
            WHEN best < 320 THEN 9
            WHEN best < 384 THEN 6
            WHEN best < 480 THEN 5
            WHEN best < 608 THEN 4
            WHEN best < 1904 THEN 3
            WHEN best < 2400 THEN 4
            WHEN best < 2880 THEN 5
            WHEN best < 3328 THEN 6
            WHEN best < 3840 THEN 7
            WHEN best < 4608 THEN 8
            WHEN best < 5120 THEN 9
            WHEN best < 6144 THEN 10
            ELSE @max_shift
          END
        )
        WHEN eventId = 'skewb' THEN
        (
          CASE
            WHEN best < 384 THEN 9
            WHEN best < 512 THEN 5
            WHEN best < 1888 THEN 4
            WHEN best < 2496 THEN 5
            WHEN best < 3072 THEN 6
            WHEN best < 3584 THEN 7
            WHEN best < 4096 THEN 8
            WHEN best < 5120 THEN 9
            ELSE @max_shift
          END
        )
        WHEN eventId = 'sq1' THEN
        (
          CASE
            WHEN best < 1280 THEN 11
            WHEN best < 5120 THEN 7
            WHEN best < 6656 THEN 8
            WHEN best < 8192 THEN 9
            WHEN best < 10240 THEN 10
            WHEN best < 12288 THEN 11
            ELSE @max_shift
          END
        )
        ELSE @max_shift
      END
    ) AS shift,
    @mask := (1 << @shift) - 1 AS mask,
    IF(@shift < @max_shift, best & ~@mask, (
      CASE
        WHEN eventId = '333' THEN 24576
        WHEN eventId = '222' THEN 5632
        WHEN eventId = '444' THEN 24576
        WHEN eventId = '555' THEN 32768
        WHEN eventId = '666' THEN 40960
        WHEN eventId = '777' THEN 49152
        WHEN eventId = '333bf' THEN 24576
        WHEN eventId = '333fm' THEN 5632
        WHEN eventId = '333oh' THEN 16384
        WHEN eventId = '333ft' THEN 24576
        WHEN eventId = 'clock' THEN 6144
        WHEN eventId = 'minx' THEN 32768
        WHEN eventId = 'pyram' THEN 6144
        WHEN eventId = 'skewb' THEN 5120
        WHEN eventId = 'sq1' THEN 12288
        ELSE 0
      END
    )) AS modified_average
  FROM
  (
    SELECT personId, eventId, age_category, MIN(average) AS best
    FROM
    (
      SELECT r.personId, r.eventId, r.average, TIMESTAMPDIFF(YEAR,
        DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'),
        DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
      FROM Persons AS p
      JOIN Results AS r ON r.personId = p.id AND average > 0
      JOIN Competitions AS c ON c.id = r.competitionId
      WHERE p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
      AND p.subid = 1
      HAVING age_at_comp >= 40
    ) AS senior_results
    JOIN
    (
      SELECT 40 AS age_category
      UNION ALL SELECT 50
      UNION ALL SELECT 60
      UNION ALL SELECT 70
      UNION ALL SELECT 80
      UNION ALL SELECT 90
      UNION ALL SELECT 100
    ) AS age_categories ON age_category <= age_at_comp
    GROUP BY personId, eventId, age_category
  ) AS senior_bests
) AS modified_bests
GROUP BY eventId, age_category, modified_average, mask
ORDER BY eventId, age_category, modified_average, mask;

/*
   Extract AGGREGATED senior results (singles)
*/

SELECT eventId, age_category, modified_single, mask, COUNT(*) AS num_persons
FROM
(
  SELECT personId, eventId, age_category,
    @shift :=
    (
      CASE
        WHEN eventId = '333' THEN
        (
          CASE
            WHEN best < 640 THEN 10
            WHEN best < 704 THEN 5
            WHEN best < 848 THEN 4
            WHEN best < 3712 THEN 3
            WHEN best < 5088 THEN 4
            WHEN best < 6400 THEN 5
            WHEN best < 7808 THEN 6
            WHEN best < 9216 THEN 7
            WHEN best < 10752 THEN 8
            WHEN best < 12288 THEN 9
            WHEN best < 14336 THEN 10
            WHEN best < 16384 THEN 11
            WHEN best < 20480 THEN 12
            ELSE @max_shift
          END
        )
        WHEN eventId = '222' THEN
        (
          CASE
            WHEN best < 96 THEN 7
            WHEN best < 128 THEN 4
            WHEN best < 192 THEN 3
            WHEN best < 904 THEN 2
            WHEN best < 1232 THEN 3
            WHEN best < 1568 THEN 4
            WHEN best < 1984 THEN 5
            WHEN best < 2304 THEN 6
            WHEN best < 2816 THEN 7
            WHEN best < 3072 THEN 8
            WHEN best < 4096 THEN 9
            ELSE @max_shift
          END
        )
        WHEN eventId = '444' THEN
        (
          CASE
            WHEN best < 2816 THEN 12
            WHEN best < 3328 THEN 7
            WHEN best < 10880 THEN 6
            WHEN best < 13824 THEN 7
            WHEN best < 16896 THEN 8
            WHEN best < 19456 THEN 9
            WHEN best < 22528 THEN 10
            WHEN best < 24576 THEN 11
            WHEN best < 32768 THEN 13
            ELSE @max_shift
          END
        )
        WHEN eventId = '555' THEN
        (
          CASE
            WHEN best < 5632 THEN 13
            WHEN best < 6144 THEN 9
            WHEN best < 6656 THEN 8
            WHEN best < 14336 THEN 7
            WHEN best < 19968 THEN 8
            WHEN best < 26624 THEN 9
            WHEN best < 30720 THEN 10
            WHEN best < 36864 THEN 11
            WHEN best < 40960 THEN 12
            ELSE @max_shift
          END
        )
        WHEN eventId = '666' THEN
        (
          CASE
            WHEN best < 11264 THEN 14
            WHEN best < 13312 THEN 10
            WHEN best < 28672 THEN 9
            WHEN best < 32768 THEN 10
            WHEN best < 40960 THEN 11
            WHEN best < 49152 THEN 12
            ELSE @max_shift
          END
        )
        WHEN eventId = '777' THEN
        (
          CASE
            WHEN best < 16384 THEN 14
            WHEN best < 18432 THEN 11
            WHEN best < 43008 THEN 10
            WHEN best < 53248 THEN 11
            WHEN best < 57344 THEN 12
            WHEN best < 65536 THEN 13
            ELSE @max_shift
          END
        )
        WHEN eventId = '333bf' THEN
        (
          CASE
            WHEN best < 4096 THEN 12
            WHEN best < 26624 THEN 10
            WHEN best < 32768 THEN 11
            WHEN best < 49152 THEN 12
            WHEN best < 57344 THEN 13
            ELSE @max_shift
          END
        )
        WHEN eventId = '333fm' THEN
        (
          CASE
            WHEN best < 24 THEN 5
            WHEN best < 28 THEN 1
            WHEN best < 54 THEN 0
            WHEN best < 60 THEN 1
            WHEN best < 64 THEN 2
            ELSE @max_shift
          END
        )
        WHEN eventId = '333oh' THEN
        (
          CASE
            WHEN best < 1024 THEN 10
            WHEN best < 1280 THEN 6
            WHEN best < 4736 THEN 5
            WHEN best < 6272 THEN 6
            WHEN best < 7680 THEN 7
            WHEN best < 9216 THEN 8
            WHEN best < 11264 THEN 9
            WHEN best < 14336 THEN 10
            WHEN best < 16384 THEN 11
            ELSE @max_shift
          END
        )
        WHEN eventId = '333ft' THEN
        (
          CASE
            WHEN best < 4096 THEN 12
            WHEN best < 16384 THEN 10
            WHEN best < 24576 THEN 11
            WHEN best < 28672 THEN 12
            ELSE @max_shift
          END
        )
        WHEN eventId = 'clock' THEN
        (
          CASE
            WHEN best < 640 THEN 10
            WHEN best < 768 THEN 7
            WHEN best < 2304 THEN 6
            WHEN best < 3328 THEN 7
            WHEN best < 4608 THEN 8
            WHEN best < 5120 THEN 9
            WHEN best < 6144 THEN 10
            ELSE @max_shift
          END
        )
        WHEN eventId = 'minx' THEN
        (
          CASE
            WHEN best < 4608 THEN 13
            WHEN best < 5632 THEN 9
            WHEN best < 18944 THEN 8
            WHEN best < 24576 THEN 9
            WHEN best < 28672 THEN 10
            WHEN best < 32768 THEN 11
            WHEN best < 40960 THEN 12
            ELSE @max_shift
          END
        )
        WHEN eventId = 'pyram' THEN
        (
          CASE
            WHEN best < 192 THEN 8
            WHEN best < 288 THEN 5
            WHEN best < 384 THEN 4
            WHEN best < 1376 THEN 3
            WHEN best < 1792 THEN 4
            WHEN best < 2240 THEN 5
            WHEN best < 2688 THEN 6
            WHEN best < 3072 THEN 7
            WHEN best < 3584 THEN 8
            WHEN best < 4096 THEN 9
            WHEN best < 5120 THEN 10
            ELSE @max_shift
          END
        )
        WHEN eventId = 'skewb' THEN
        (
          CASE
            WHEN best < 192 THEN 8
            WHEN best < 288 THEN 5
            WHEN best < 1344 THEN 4
            WHEN best < 1792 THEN 5
            WHEN best < 2304 THEN 6
            WHEN best < 2816 THEN 7
            WHEN best < 3584 THEN 8
            WHEN best < 4096 THEN 9
            ELSE @max_shift
          END
        )
        WHEN eventId = 'sq1' THEN
        (
          CASE
            WHEN best < 1024 THEN 10
            WHEN best < 4864 THEN 7
            WHEN best < 6656 THEN 8
            WHEN best < 8192 THEN 9
            WHEN best < 10240 THEN 10
            WHEN best < 12288 THEN 11
            ELSE @max_shift
          END
        )
        WHEN eventId = '444bf' THEN
        (
          CASE
            WHEN best < 32768 THEN 15
            WHEN best < 65536 THEN 14
            WHEN best < 98304 THEN 15
            ELSE @max_shift
          END
        )
        WHEN eventId = '555bf' THEN
        (
          CASE
            WHEN best < 131072 THEN 16
            ELSE @max_shift
          END
        )
        WHEN eventId = '333mbf' THEN
        (
          CASE
            WHEN best < 880000000 THEN 30
            WHEN best < 910000000 THEN 25
            WHEN best < 940000000 THEN 24
            ELSE 19
          END
        )
        ELSE @max_shift
      END
    ) AS shift,
    @mask := (1 << @shift) - 1 AS mask,
    IF(@shift < @max_shift, best & ~@mask, (
      CASE
        WHEN eventId = '333' THEN 20480
        WHEN eventId = '222' THEN 4096
        WHEN eventId = '444' THEN 32768
        WHEN eventId = '555' THEN 40960
        WHEN eventId = '666' THEN 49152
        WHEN eventId = '777' THEN 65536
        WHEN eventId = '333bf' THEN 57344
        WHEN eventId = '333fm' THEN 64
        WHEN eventId = '333oh' THEN 16384
        WHEN eventId = '333ft' THEN 28672
        WHEN eventId = 'clock' THEN 6144
        WHEN eventId = 'minx' THEN 40960
        WHEN eventId = 'pyram' THEN 5120
        WHEN eventId = 'skewb' THEN 4096
        WHEN eventId = 'sq1' THEN 12288
        WHEN eventId = '444bf' THEN 98304
        WHEN eventId = '555bf' THEN 131072
        ELSE 0
      END
    )) AS modified_single
  FROM
  (
    SELECT personId, eventId, age_category, MIN(best) AS best
    FROM
    (
      SELECT r.personId, r.eventId, r.best, TIMESTAMPDIFF(YEAR,
        DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'),
        DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
      FROM Persons AS p
      JOIN Results AS r ON r.personId = p.id AND best > 0
      JOIN Competitions AS c ON c.id = r.competitionId
      WHERE p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
      AND p.subid = 1
      HAVING age_at_comp >= 40
    ) AS senior_results
    JOIN
    (
      SELECT 40 AS age_category
      UNION ALL SELECT 50
      UNION ALL SELECT 60
      UNION ALL SELECT 70
      UNION ALL SELECT 80
      UNION ALL SELECT 90
      UNION ALL SELECT 100
    ) AS age_categories ON age_category <= age_at_comp
    GROUP BY personId, eventId, age_category
  ) AS senior_bests
) AS modified_bests
GROUP BY eventId, age_category, modified_single, mask
ORDER BY eventId, age_category, modified_single, mask;
