/*
 * tb_reservations 테이블의 반려 상태를 자동으로 업데이트하는 쿼리
 *
 * 조건:
 * 1. 예약 상태가 '1차 승인 대기'이거나 '2차 승인 대기'인 경우 (reservation_status_id = 1 or 2)
 * 2. 예약 날짜가 오늘이거나 지난 경우 (reservation_from = CURRENT_DATE or reservation_to < NOW())
 *
 * 위 조건을 모두 만족하는 예약의 상태를 '반려' (reservation_status_id = 4)로 변경
 */
WITH updated_reservations AS (
    UPDATE tb_reservations
    SET reservation_status_id = 4
    WHERE 
        (reservation_status_id = 1 OR reservation_status_id = 2) 
        AND (DATE(reservation_from) = CURRENT_DATE OR reservation_to < NOW())
    RETURNING reservation_id
)

-- 위에서 업데이트된 예약들의 정보를 사용하여 반려 사유를 기록합니다.
INSERT INTO tb_reservation_logs (
    memo,
    reg_date,
    changed_status_id,
    reservation_id
)
SELECT '승인 기간 초과로 인해 자동 반려 처리 - 관리자에게 문의하세요', -- memo_text
       NOW(),           -- reg_date (현재 시각)
       4,               -- changed_status_id
       reservation_id   -- reservation_id
FROM   updated_reservations;