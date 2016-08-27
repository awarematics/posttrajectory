package com.postTraj.Main;

import java.io.*;
import java.sql.*;

import com.postTraj.InsertTraj.Insert_Data;

public class InsertData_To_SubTable_Main {

	public static void main(String[] args) throws IOException, SQLException {

		Insert_Data main = new Insert_Data();

		main.dbcon();

		String schemeName = "public";
		String tbName = "mpseq_traj_data";

		long start = System.currentTimeMillis();

		if (main.exist_table(schemeName, tbName)) {
			main.insert_files(150, "/root/DataSet/", "subTb");
			// main.insert_files(150, "/root/00010/", "subTb");
		}

		long end = System.currentTimeMillis();

		System.out.println("Total Time : " + (end - start) / 1000.0);

		main.dbclose();
	}
}
