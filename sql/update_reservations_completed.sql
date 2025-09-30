/*
 * tb_reservations 테이블의 예약 상태를 자동으로 업데이트하는 쿼리
 *
 * 조건:
 * 1. 예약 상태가 '최종 승인 완료'인 경우 (reservation_status_id = 3)
 * 2. 예약 종료 시간이 현재 시간보다 지난 경우 (reservation_to < NOW())
 *
 * 위 조건을 모두 만족하는 예약의 상태를 '이용완료' (reservation_status_id = 5)로 변경
 */
 
UPDATE tb_reservations
SET reservation_status_id = 5
WHERE reservation_status_id = 3 AND reservation_to < NOW();