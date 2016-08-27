package com.postTraj.Main;

import java.sql.SQLException;

import com.postTraj.InsertTraj.Insert_Data;

public class InsertData_To_SegmentTable_Main {

	public static void main(String[] args) throws SQLException {

		Insert_Data main = new Insert_Data();

		main.dbcon();

		long start = System.currentTimeMillis();

		String filePath = "/root/DataSet/";
//		String filePath = "/root/00010/";

		// main.data_insert(150, "/root/DataSet/00002/7173.txt");

		main.insert_files(150, filePath, "segmentTb");

		long end = System.currentTimeMillis();

		System.out.println("Total Time : " + (end - start) / 1000.0);

		main.dbclose();

	}
}
