/*
    Script:   Check time bands
    Created:  2019-09-01
    Author:   Michael George / 2015GEOR02

    Purpose:  Check time bands for "Indicative Senior Rankings"
              https://logiqx.github.io/wca-ipy/Indicative_Rankings.html

    Notes:    Average group size should exceed 200, minium group size should exceed 100
*/

SET @eventId = '444';

SELECT MIN(numPersons), AVG(numPersons), MAX(numPersons), STDDEV(numPersons)
FROM
(
	SELECT modified_best, MIN(shift), MAX(shift), MAX(shift) - MIN(shift) AS shift_diff, MIN(best), MAX(best),
		MIN(min_best), MAX(max_best), MIN(min_best) = modified_best AS min_eq, MAX(max_best) = modified_best AS max_eq, COUNT(*) AS numPersons
	FROM
	(
		SELECT best,
			@shift :=
			(
				CASE
					WHEN r.eventId IN ('333') THEN
					(
						CASE
							WHEN best < 640 THEN 10
							WHEN best < 688 THEN 6
							WHEN best < 841 THEN 4
							WHEN best < 3712 THEN 3
							WHEN best < 5088 THEN 4
							WHEN best < 6400 THEN 5
							WHEN best < 7808 THEN 6
							WHEN best < 9216 THEN 7
							WHEN best < 10752 THEN 8
							WHEN best < 12288 THEN 9
                            WHEN best < 14336 THEN 10
                            WHEN best < 16405 THEN 11
                            WHEN best < 18484 THEN 12
							ELSE 20
						END
					)
					WHEN r.eventId IN ('222') THEN
					(
						CASE
							WHEN best < 96 THEN 9
							WHEN best < 144 THEN 4
							WHEN best < 192 THEN 3
							WHEN best < 898 THEN 2
							WHEN best < 1232 THEN 3
							WHEN best < 1568 THEN 4
							WHEN best < 1936 THEN 5
							WHEN best < 2304 THEN 6
							WHEN best < 2816 THEN 7
							WHEN best < 3072 THEN 8
							WHEN best < 4096 THEN 9
							ELSE 20
						END
					)
					WHEN r.eventId IN ('444') THEN
					(
						CASE
							WHEN best < 2816 THEN 12
							WHEN best < 3411 THEN 7
							WHEN best < 10880 THEN 6
							WHEN best < 13824 THEN 7
							WHEN best < 16896 THEN 8
							WHEN best < 19456 THEN 9
							WHEN best < 22528 THEN 10
							WHEN best < 24576 THEN 11
							WHEN best < 28204 THEN 12
							WHEN best < 32768 THEN 13
							ELSE 20
						END
					)
					WHEN r.eventId IN ('333oh') THEN
					(
						CASE
							WHEN best < 1024 THEN 10
							WHEN best < 1280 THEN 6
							WHEN best < 4736 THEN 5
							WHEN best < 6272 THEN 6
							WHEN best < 7680 THEN 7
							WHEN best < 9216 THEN 8
							WHEN best < 11264 THEN 9
                            WHEN best < 12288 THEN 10
                            WHEN best < 14233 THEN 11
                            WHEN best < 16384 THEN 12
                            WHEN best < 22246 THEN 14
							ELSE 20
						END
					)
					WHEN r.eventId IN ('pyram') THEN
					(
						CASE
							WHEN best < 197 THEN 9
							WHEN best < 234 THEN 6
							WHEN best < 288 THEN 5
							WHEN best < 376 THEN 4
							WHEN best < 1376 THEN 3
							WHEN best < 1792 THEN 4
							WHEN best < 2240 THEN 5
							WHEN best < 2688 THEN 6
							WHEN best < 3072 THEN 7
							WHEN best < 3587 THEN 8
							WHEN best < 4100 THEN 9
							WHEN best < 4505 THEN 10
							ELSE 20
						END
					)
					WHEN r.eventId IN ('skewb') THEN
					(
						CASE
							WHEN best < 192 THEN 9
							WHEN best < 288 THEN 5
							WHEN best < 1321 THEN 4
							WHEN best < 1792 THEN 5
							WHEN best < 2304 THEN 6
							WHEN best < 2816 THEN 7
							WHEN best < 3313 THEN 8
							WHEN best < 4096 THEN 9
							ELSE 20
						END
					)
					ELSE 1
				END
			) AS shift,
			@turning_point :=
			(
				CASE
					WHEN r.eventId IN ('333') THEN 1760
					WHEN r.eventId IN ('222') THEN 416
					WHEN r.eventId IN ('444') THEN 6080
					WHEN r.eventId IN ('333oh') THEN 2432
					WHEN r.eventId IN ('pyram') THEN 720
					WHEN r.eventId IN ('skewb') THEN 624
					ELSE 1
				END
			) AS turning_point,
			@mask := (1 << @shift) - 1 AS mask,
			IF(best < @turning_point, best & ~@mask, best | @mask) AS modified_best,
			best & ~@mask AS min_best,
			best | @mask AS max_best
		FROM RanksSingle AS r
		WHERE r.eventId = @eventId
	) AS t
	GROUP BY modified_best
) AS t;

SELECT MIN(numPersons), AVG(numPersons), MAX(numPersons), STDDEV(numPersons)
FROM
(
	SELECT modified_best, MIN(shift), MAX(shift), MAX(shift) - MIN(shift) AS shift_diff, MIN(best), MAX(best),
		MIN(min_best), MAX(max_best), MIN(min_best) = modified_best AS min_eq, MAX(max_best) = modified_best AS max_eq, COUNT(*) AS numPersons
	FROM
	(
		SELECT best,
			@shift :=
			(
				CASE
					WHEN r.eventId IN ('333') THEN
					(
						CASE
							WHEN best < 768 THEN 10
							WHEN best < 880 THEN 6
							WHEN best < 1024 THEN 4
							WHEN best < 4200 THEN 3
							WHEN best < 5952 THEN 4
							WHEN best < 7488 THEN 5
							WHEN best < 9088 THEN 6
							WHEN best < 10752 THEN 7
							WHEN best < 12800 THEN 8
							WHEN best < 14336 THEN 9
                            WHEN best < 16384 THEN 10
                            WHEN best < 20480 THEN 11
                            WHEN best < 24029 THEN 13
							ELSE 20
						END
					)
					WHEN r.eventId IN ('222') THEN
					(
						CASE
							WHEN best < 224 THEN 9
							WHEN best < 272 THEN 5
							WHEN best < 344 THEN 3
							WHEN best < 1200 THEN 2
							WHEN best < 1664 THEN 3
							WHEN best < 2128 THEN 4
							WHEN best < 2560 THEN 5
							WHEN best < 3072 THEN 6
							WHEN best < 3584 THEN 7
							WHEN best < 4096 THEN 8
							WHEN best < 4536 THEN 9
							WHEN best < 5105 THEN 10
							WHEN best < 5711 THEN 11
							WHEN best < 7045 THEN 12
							ELSE 20
						END
					)
					WHEN r.eventId IN ('444') THEN
					(
						CASE
							WHEN best < 3200 THEN 12
							WHEN best < 3456 THEN 9
							WHEN best < 3840 THEN 7
							WHEN best < 9344 THEN 6
							WHEN best < 11648 THEN 7
							WHEN best < 13824 THEN 8
							WHEN best < 15800 THEN 9
                            WHEN best < 18432 THEN 10
                            WHEN best < 20480 THEN 11
                            WHEN best < 23376 THEN 12
							ELSE 20
						END
					)
					WHEN r.eventId IN ('333oh') THEN
					(
						CASE
							WHEN best < 1408 THEN 11
							WHEN best < 1664 THEN 6
							WHEN best < 4704 THEN 5
							WHEN best < 5952 THEN 6
							WHEN best < 8704 THEN 8
							WHEN best < 10240 THEN 9
                            WHEN best < 10947 THEN 10
                            WHEN best < 12288 THEN 11
                            WHEN best < 16384 THEN 12
							ELSE 20
						END
					)
					WHEN r.eventId IN ('pyram') THEN
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
							WHEN best < 5962 THEN 10
							ELSE 20
						END
					)
					WHEN r.eventId IN ('skewb') THEN
					(
						CASE
							WHEN best < 384 THEN 9
							WHEN best < 512 THEN 5
							WHEN best < 1888 THEN 4
							WHEN best < 2464 THEN 5
							WHEN best < 3072 THEN 6
							WHEN best < 3584 THEN 7
							WHEN best < 4096 THEN 8
							WHEN best < 5120 THEN 9
							ELSE 20
						END
					)
					ELSE 1
				END
			) AS shift,
			@turning_point :=
			(
				CASE
					WHEN r.eventId IN ('333') THEN 2112
					WHEN r.eventId IN ('222') THEN 644
					WHEN r.eventId IN ('444') THEN 6080
					WHEN r.eventId IN ('333oh') THEN 2848
					WHEN r.eventId IN ('pyram') THEN 1072
					WHEN r.eventId IN ('skewb') THEN 992
					ELSE 1
				END
			) AS turning_point,
			@mask := (1 << @shift) - 1 AS mask,
			IF(best < @turning_point, best & ~@mask, best | @mask) AS modified_best,
			best & ~@mask AS min_best,
			best | @mask AS max_best
		FROM RanksAverage AS r
		WHERE r.eventId = @eventId
	) AS t
	GROUP BY modified_best
) AS t;