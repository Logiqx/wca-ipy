/*
    Script:   Check time bands
    Created:  2019-09-01
    Author:   Michael George / 2015GEOR02

    Purpose:  Check time bands for "Indicative Senior Rankings"
              https://logiqx.github.io/wca-ipy/Indicative_Rankings.html

    Notes:    Average group size should exceed 200, minium group size should exceed 100
*/

SET @eventId = '444';

SELECT eventId, COUNT(*) AS numGroups, MIN(group_range), MIN(numPersons), AVG(numPersons), MAX(numPersons), STDDEV(numPersons)
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
							ELSE 20
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
							ELSE 20
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
							ELSE 20
						END
					)
					WHEN eventId = '555' THEN
					(
						CASE
							WHEN best < 5632 THEN 13
							WHEN best < 6656 THEN 8
							WHEN best < 15360 THEN 7
							WHEN best < 19968 THEN 8
							WHEN best < 26624 THEN 9
							WHEN best < 30720 THEN 10
							WHEN best < 36864 THEN 11
							WHEN best < 40960 THEN 12
							ELSE 20
						END
					)
					WHEN eventId = '666' THEN
					(
						CASE
							WHEN best < 11264 THEN 14
							WHEN best < 12287 THEN 10
							WHEN best < 28672 THEN 9
							WHEN best < 32768 THEN 10
							WHEN best < 40960 THEN 11
							WHEN best < 49152 THEN 12
							ELSE 20
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
							ELSE 20
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
							ELSE 20
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
							ELSE 20
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
							ELSE 20
						END
					)
					WHEN eventId = '333ft' THEN
					(
						CASE
							WHEN best < 4096 THEN 12
							WHEN best < 16383 THEN 10
							WHEN best < 24576 THEN 11
							WHEN best < 28672 THEN 12
							ELSE 20
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
							ELSE 20
						END
					)
					WHEN eventId = 'minx' THEN
					(
						CASE
							WHEN best < 4608 THEN 13
							WHEN best < 5632 THEN 9
							WHEN best < 18943 THEN 8
							WHEN best < 24576 THEN 9
							WHEN best < 28672 THEN 10
							WHEN best < 32768 THEN 11
							WHEN best < 40960 THEN 12
							ELSE 20
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
							WHEN best < 3587 THEN 8
							WHEN best < 4096 THEN 9
							WHEN best < 5120 THEN 10
							ELSE 20
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
							ELSE 20
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
							ELSE 20
						END
					)
					WHEN eventId = '444bf' THEN
					(
						CASE
							WHEN best < 32768 THEN 15
							WHEN best < 65535 THEN 14
							WHEN best < 98304 THEN 15
							ELSE 20
						END
					)
					WHEN eventId = '555bf' THEN
					(
						CASE
							WHEN best < 131072 THEN 16
							ELSE 20
						END
					)
					WHEN eventId = '333mbf' THEN
					(
						CASE
							WHEN FLOOR(best / 10000000) >= 94 THEN 0
							WHEN FLOOR(best / 10000000) >= 88 THEN 2
							ELSE 20
						END
					)
					ELSE 10
				END
			) AS shift,
			@turning_point :=
			(
				CASE
					WHEN eventId = '333' THEN 1760
					WHEN eventId = '222' THEN 416
					WHEN eventId = '444' THEN 6080
					WHEN eventId = '555' THEN 10880
					WHEN eventId = '666' THEN 18944
					WHEN eventId = '777' THEN 27648
					WHEN eventId = '333bf' THEN 10240
					WHEN eventId = '333fm' THEN 38
					WHEN eventId = '333oh' THEN 2432
					WHEN eventId = '333ft' THEN 7168
					WHEN eventId = 'clock' THEN 1280
					WHEN eventId = 'minx' THEN 10240
					WHEN eventId = 'pyram' THEN 720
					WHEN eventId = 'skewb' THEN 624
					WHEN eventId = 'sq1' THEN 2176
					WHEN eventId = '444bf' THEN 32768
					WHEN eventId = '555bf' THEN 65536
					WHEN eventId = '333mbf' THEN 970000000
					ELSE 0
				END
			) AS turning_point,
			@mask := (1 << @shift) - 1 AS mask,
			IF(eventId = '333mbf',
				IF(best > @turning_point, 99 - FLOOR(best / 10000000) & ~@mask, 99 - FLOOR(best / 10000000) | @mask),
				IF(best < @turning_point, best & ~@mask, best | @mask)) AS modified_best,
			best & ~@mask AS min_best,
			best | @mask AS max_best
		FROM RanksSingle AS r
	) AS t
	GROUP BY eventId, modified_best
) AS t
GROUP BY eventId;

SELECT eventId, COUNT(*) AS numGroups, MIN(group_range), MIN(numPersons), AVG(numPersons), MAX(numPersons), STDDEV(numPersons)
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
							WHEN best < 4192 THEN 3
							WHEN best < 5952 THEN 4
							WHEN best < 7488 THEN 5
							WHEN best < 9088 THEN 6
							WHEN best < 10752 THEN 7
							WHEN best < 12800 THEN 8
							WHEN best < 14336 THEN 9
                            WHEN best < 16384 THEN 10
                            WHEN best < 20480 THEN 11
                            WHEN best < 24576 THEN 12
							ELSE 20
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
							ELSE 20
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
							ELSE 20
						END
					)
					WHEN eventId = '555' THEN
					(
						CASE
							WHEN best < 6400 THEN 13
							WHEN best < 7424 THEN 8
							WHEN best < 14848 THEN 7
							WHEN best < 16896 THEN 8
							WHEN best < 20480 THEN 9
							WHEN best < 22528 THEN 10
							WHEN best < 24576 THEN 11
							WHEN best < 32768 THEN 12
							ELSE 20
						END
					)
					WHEN eventId = '666' THEN
					(
						CASE
							WHEN best < 11264 THEN 14
							WHEN best < 14336 THEN 10
							WHEN best < 24576 THEN 9
							WHEN best < 28672 THEN 10
							WHEN best < 32768 THEN 11
							WHEN best < 40960 THEN 13
							ELSE 20
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
							ELSE 20
						END
					)
					WHEN eventId = '333bf' THEN
					(
						CASE
							WHEN best < 4096 THEN 12
							WHEN best < 20480 THEN 11
							WHEN best < 24576 THEN 12
							ELSE 20
						END
					)
					WHEN eventId = '333fm' THEN
					(
						CASE
							WHEN best < 3100 THEN 12
							WHEN best < 3333 THEN 8
							WHEN best < 4633 THEN 7
							WHEN best < 5133 THEN 8
							WHEN best < 5632 THEN 9
							ELSE 20
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
							ELSE 20
						END
					)
					WHEN eventId = '333ft' THEN
					(
						CASE
							WHEN best < 5120 THEN 13
							WHEN best < 14336 THEN 10
							WHEN best < 20480 THEN 11
							WHEN best < 24576 THEN 12
							ELSE 20
						END
					)
					WHEN eventId = 'clock' THEN
					(
						CASE
							WHEN best < 768 THEN 10
							WHEN best < 896 THEN 7
							WHEN best < 2176 THEN 6
							WHEN best < 3328 THEN 7
							WHEN best < 3584 THEN 8
							WHEN best < 5120 THEN 9
							WHEN best < 6144 THEN 10
							ELSE 20
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
							ELSE 20
						END
					)
					WHEN eventId = 'pyram' THEN
					(
						CASE
							WHEN best < 340 THEN 9
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
							ELSE 20
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
							ELSE 20
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
							ELSE 20
						END
					)
					WHEN eventId = '444bf' THEN 20
					WHEN eventId = '555bf' THEN 20
					ELSE 10
				END
			) AS shift,
			@turning_point :=
			(
				CASE
					WHEN eventId = '333' THEN 2112
					WHEN eventId = '222' THEN 644
					WHEN eventId = '444' THEN 6080
					WHEN eventId = '555' THEN 10624
					WHEN eventId = '666' THEN 18432
					WHEN eventId = '777' THEN 26624
					WHEN eventId = '333bf' THEN 6144
					WHEN eventId = '333fm' THEN 3867
					WHEN eventId = '333oh' THEN 2848
					WHEN eventId = '333ft' THEN 8192
					WHEN eventId = 'clock' THEN 1472
					WHEN eventId = 'minx' THEN 9728
					WHEN eventId = 'pyram' THEN 1072
					WHEN eventId = 'skewb' THEN 992
					WHEN eventId = 'sq1' THEN 2560
					WHEN eventId = '444bf' THEN 0
					WHEN eventId = '555bf' THEN 0
					ELSE 0
				END
			) AS turning_point,
			@mask := (1 << @shift) - 1 AS mask,
			IF(best < @turning_point, best & ~@mask, best | @mask) AS modified_best,
			best & ~@mask AS min_best,
			best | @mask AS max_best
		FROM RanksAverage AS r
	) AS t
	GROUP BY eventId, modified_best
) AS t
GROUP BY eventId;
