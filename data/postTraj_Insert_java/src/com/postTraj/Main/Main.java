package com.postTraj.Main;

import java.io.*;
import java.sql.*;

import com.postTraj.InsertTraj.Insert_Data;

public class Main {

	public static void main(String[] args) throws IOException, SQLException {

		Insert_Data main = new Insert_Data();

		main.dbcon();

		String schemeName = "public";
		String tbName = "mpseq_traj_data";
		
		long start = System.currentTimeMillis();

//		String filePath = "/root/DataSet/00002/650.txt";
		// String filePath = "/root/DataSet/00001/366.txt";

		// main.data_insert(150, filePath);
		// main.insert_mqseqTrajData(1000, filePath);

		if (main.exist_table(schemeName, tbName)) {
			main.insert_files(150, "D:/00010/");
		}

		long end = System.currentTimeMillis();

		System.out.println("Total Time : " + (end - start) / 1000.0);

		main.dbclose();
	}
}
