/*
    Script:   Check time bands
    Created:  2019-09-01
    Author:   Michael George / 2015GEOR02

    Purpose:  Check time bands for "Indicative Senior Rankings"
              https://logiqx.github.io/wca-ipy/Indicative_Rankings.html

    Notes:    Average group size should exceed 200, minium group size should exceed 100
*/

SET @max_shift = 31;
SET @eventId = '666';

SELECT * -- eventId, COUNT(*) AS numGroups, MIN(group_range), MIN(numPersons), AVG(numPersons), MAX(numPersons), STDDEV(numPersons)
FROM
(
  SELECT eventId, modified_best, MIN(shift), MAX(shift), MAX(shift) - MIN(shift) AS shift_diff, MIN(best), MAX(best), MAX(max_best) - MIN(min_best) + 1 AS group_range,
    MIN(min_best), MAX(max_best), MIN(min_best) = modified_best AS min_eq, MAX(max_best) = modified_best AS max_eq, COUNT(*) AS numPersons
  FROM
  (
    SELECT eventId, best,
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
              WHEN best < 15360 THEN 7
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
              WHEN best < 12288 THEN 10
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
          ELSE 1 << @max_shift
        END
      )) AS modified_best,
      best & ~@mask AS min_best,
      best | @mask AS max_best
    FROM RanksSingle AS r
    -- WHERE eventId = @eventId
  ) AS t
  GROUP BY eventId, modified_best
) AS t
WHERE numPersons < 100;
-- GROUP BY eventId;

SELECT * -- eventId, COUNT(*) AS numGroups, MIN(group_range), MIN(numPersons), AVG(numPersons), MAX(numPersons), STDDEV(numPersons)
FROM
(
  SELECT eventId, modified_best, MIN(shift), MAX(shift), MAX(shift) - MIN(shift) AS shift_diff, MIN(best), MAX(best), MAX(max_best) - MIN(min_best) + 1 AS group_range,
    MIN(min_best), MAX(max_best), MIN(min_best) = modified_best AS min_eq, MAX(max_best) = modified_best AS max_eq, COUNT(*) AS numPersons
  FROM
  (
    SELECT eventId, best,
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
          ELSE 1 << @max_shift
        END
      )) AS modified_best,
      best & ~@mask AS min_best,
      best | @mask AS max_best
    FROM RanksAverage AS r
    -- WHERE eventId = @eventId
  ) AS t
  GROUP BY eventId, modified_best
) AS t
WHERE numPersons < 100;
-- GROUP BY eventId;
