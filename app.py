"""
Python demo for tasks 10, 11, 12 of the Hotel Management project.

Tasks:
10. Assign employee to process booking
11. Revenue + booking report by month / week
12. Room utilization report

Requirement:
    pip install mysql-connector-python

Before running this file:
1. Create database and tables.
2. Run task_10_11_12_hotel_objects.sql
3. Update DB_CONFIG below.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, List, Sequence
import sys

import mysql.connector
from mysql.connector import Error


DB_CONFIG = {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "Tuan2006",
    "database": "hotel_management",
}


@dataclass
class QueryResult:
    headers: List[str]
    rows: List[Sequence[object]]


class HotelTaskService:
    def __init__(self, config: dict):
        self.config = config

    def _get_connection(self):
        return mysql.connector.connect(**self.config)

    def _run_query(self, query: str, params: Sequence[object] | None = None) -> QueryResult:
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute(query, params or ())
            rows = cursor.fetchall()
            headers = [desc[0] for desc in cursor.description] if cursor.description else []
            return QueryResult(headers=headers, rows=rows)
        finally:
            cursor.close()
            conn.close()

    def _call_procedure(self, name: str, args: Sequence[object]) -> QueryResult:
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc(name, args)
            headers: List[str] = []
            rows: List[Sequence[object]] = []

            for result in cursor.stored_results():
                if result.description:
                    headers = [desc[0] for desc in result.description]
                    rows = result.fetchall()

            conn.commit()
            return QueryResult(headers=headers, rows=rows)
        finally:
            cursor.close()
            conn.close()

    # ---------- TASK 10 ----------
    def assign_employee_to_booking(self, booking_id: str, employee_id: str) -> QueryResult:
        return self._call_procedure("sp_assign_employee_to_booking", [booking_id, employee_id])

    def get_booking_assignment_view(self) -> QueryResult:
        query = """
            SELECT *
            FROM vw_booking_assignment
            ORDER BY Booking_Date DESC, Booking_ID;
        """
        return self._run_query(query)

    # ---------- TASK 11 ----------
    def get_monthly_report(self, year: int) -> QueryResult:
        return self._call_procedure("sp_report_monthly_revenue_bookings", [year])

    def get_weekly_report(self, year: int) -> QueryResult:
        return self._call_procedure("sp_report_weekly_revenue_bookings", [year])

    def get_monthly_view(self) -> QueryResult:
        query = """
            SELECT *
            FROM vw_monthly_revenue_bookings
            ORDER BY Report_Year, Report_Month;
        """
        return self._run_query(query)

    def get_weekly_view(self) -> QueryResult:
        query = """
            SELECT *
            FROM vw_weekly_revenue_bookings
            ORDER BY Report_Year, Report_Week;
        """
        return self._run_query(query)

    # ---------- TASK 12 ----------
    def get_room_utilization_report(self, start_date: str, end_date: str) -> QueryResult:
        return self._call_procedure("sp_room_utilization_report", [start_date, end_date])

    def get_room_booking_nights_view(self) -> QueryResult:
        query = """
            SELECT *
            FROM vw_room_booking_nights
            ORDER BY Room_Number, Booking_ID;
        """
        return self._run_query(query)

    def get_room_utilization_percent(self, room_id: str, start_date: str, end_date: str) -> QueryResult:
        query = """
            SELECT
                %s AS Room_ID,
                %s AS Start_Date,
                %s AS End_Date,
                fn_room_utilization_percent(%s, %s, %s) AS Utilization_Percent;
        """
        params = (room_id, start_date, end_date, room_id, start_date, end_date)
        return self._run_query(query, params)


def format_value(value: object) -> str:
    if value is None:
        return "NULL"
    return str(value)


def print_table(result: QueryResult) -> None:
    if not result.headers:
        print("Khong co du lieu de hien thi.")
        return

    rows_as_text = [[format_value(value) for value in row] for row in result.rows]
    widths = [len(header) for header in result.headers]

    for row in rows_as_text:
        for i, cell in enumerate(row):
            widths[i] = max(widths[i], len(cell))

    def build_line(char: str = "-") -> str:
        return "+" + "+".join(char * (width + 2) for width in widths) + "+"

    print(build_line("-"))
    print(
        "| "
        + " | ".join(header.ljust(widths[i]) for i, header in enumerate(result.headers))
        + " |"
    )
    print(build_line("="))

    for row in rows_as_text:
        print("| " + " | ".join(cell.ljust(widths[i]) for i, cell in enumerate(row)) + " |")
    print(build_line("-"))
    print(f"Tong so dong: {len(result.rows)}")

MENU = """
================ HOTEL TASK MENU ================
1. Task 10 - Phan cong nhan vien xu ly dat phong
2. Task 10 - Xem view phan cong dat phong
3. Task 11 - Bao cao doanh thu va dat phong theo thang
4. Task 11 - Bao cao doanh thu va dat phong theo tuan
5. Task 11 - Xem view tong hop theo thang
6. Task 11 - Xem view tong hop theo tuan
7. Task 12 - Bao cao hieu suat khai thac phong
8. Task 12 - Xem view so dem su dung cua tung booking
9. Task 12 - Tinh phan tram khai thac cua 1 phong
0. Thoat
=================================================
"""

def main() -> None:
    service = HotelTaskService(DB_CONFIG)

    try:
        while True:
            print(MENU)
            choice = input("Chon chuc nang: ").strip()

            try:
                if choice == "1":
                    booking_id = input("Nhap Booking_ID: ").strip()
                    employee_id = input("Nhap Employee_ID: ").strip()
                    result = service.assign_employee_to_booking(booking_id, employee_id)
                    print_table(result)

                elif choice == "2":
                    result = service.get_booking_assignment_view()
                    print_table(result)

                elif choice == "3":
                    year = int(input("Nhap nam can bao cao: ").strip())
                    result = service.get_monthly_report(year)
                    print_table(result)

                elif choice == "4":
                    year = int(input("Nhap nam can bao cao: ").strip())
                    result = service.get_weekly_report(year)
                    print_table(result)

                elif choice == "5":
                    result = service.get_monthly_view()
                    print_table(result)

                elif choice == "6":
                    result = service.get_weekly_view()
                    print_table(result)

                elif choice == "7":
                    start_date = input("Nhap ngay bat dau (YYYY-MM-DD): ").strip()
                    end_date = input("Nhap ngay ket thuc (YYYY-MM-DD): ").strip()
                    result = service.get_room_utilization_report(start_date, end_date)
                    print_table(result)

                elif choice == "8":
                    result = service.get_room_booking_nights_view()
                    print_table(result)

                elif choice == "9":
                    room_id = input("Nhap Room_ID: ").strip()
                    start_date = input("Nhap ngay bat dau (YYYY-MM-DD): ").strip()
                    end_date = input("Nhap ngay ket thuc (YYYY-MM-DD): ").strip()
                    result = service.get_room_utilization_percent(room_id, start_date, end_date)
                    print_table(result)

                elif choice == "0":
                    print("Da thoat chuong trinh.")
                    break

                else:
                    print("Lua chon khong hop le. Vui long chon lai.")

            except ValueError:
                print("Du lieu nhap vao khong hop le.")
            except Error as db_error:
                print(f"Loi MySQL: {db_error}")
            except Exception as exc:  # noqa: BLE001
                print(f"Loi: {exc}")

    except KeyboardInterrupt:
        print("\nDa dung chuong trinh.")
        sys.exit(0)


if __name__ == "__main__":
    main()
