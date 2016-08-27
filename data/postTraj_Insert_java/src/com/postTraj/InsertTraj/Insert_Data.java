package com.postTraj.InsertTraj;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Arrays;

import com.postTraj.DBConnector.DBConnector;
import com.postTraj.Query.Make_Query;
import com.postTraj.Query.Tokenize_data;
import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.Envelope;
import com.vividsolutions.jts.geom.Geometry;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.Point;

public class Insert_Data {
	File[] file_name;
	String table_name;
	ResultSet rs, rs1;

	BufferedReader in;

	DBConnector dbconn = new DBConnector();

	public void dbcon() {
		if (dbconn.dbconnector()) {
			System.out.println("DB Connect Success!");
		} else {
			System.out.println("DB Connect Fail!");
		}
	}

	public void dbclose() {
		System.out.println("DB closed");
		dbconn.closeDB();
	}

	public File[] get_fileArr(String path) {

		File f = new File(path);

		File[] result = new File[1];

		File[] pathArr = f.listFiles();

		File tmp_file;
		String dir_name = "";

		for (int i = 0; i < pathArr.length; i++) {

			if (pathArr[i].isDirectory()) {
				if (pathArr[i].getAbsolutePath().length() != 5) {

					dir_name = pathArr[i].getName();

					for (; dir_name.length() < 5;) {
						dir_name = "0" + dir_name;
					}
					tmp_file = new File(pathArr[i].getAbsolutePath());
					tmp_file.renameTo(new File(pathArr[i].getParent() + "/" + dir_name));

				} else {
					tmp_file = new File(pathArr[i].getAbsolutePath());
				}
			}
		}

		Arrays.sort(pathArr);

		int total = 0;

		for (int i = 0; i < pathArr.length; i++) {
			if (pathArr[i].isDirectory()) {
				// System.out.println(pathArr[i].getAbsolutePath());
				total += pathArr[i].list().length;
			} else {
				total++;
			}
		}
		// System.out.println(total);

		result = new File[total];

		File[] tmpArr;
		int srcPos = 0;

		for (int i = 0; i < pathArr.length; i++) {
			tmpArr = pathArr[i].listFiles();

			Arrays.sort(tmpArr);
			for (int j = 0; j < tmpArr.length; j++) {
				result[srcPos] = tmpArr[j];
				srcPos++;
			}
		}

		for (int i = 0; i < result.length; i++) {
			System.out.println(i + " : " + result[i]);
		}

		return result;
	}

	/*
	 * Insert Data of files
	 * 
	 */
	public void data_insert(int cnt) throws SQLException {

		long start = System.currentTimeMillis();

		int segId = 0, next_segId = 0, before_segId = 0, mpId = 0;

		String start_time = "", end_time = "";

		Make_Query query = new Make_Query();

		String filePath = "/root/DataSet/";
		file_name = get_fileArr(filePath);

		for (int t = 0; t < file_name.length; t++) {
			// System.out.println(file_name[t].getAbsolutePath());
			try {
				in = new BufferedReader(new FileReader(file_name[t]));
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			segId = 0;

			String data;

			boolean isTaxiNum = false;

			try {

				int tp_cnt = 0;

				String ptArr = "", tpArr = "", start_pt = "", segTableName = "";

				Tokenize_data tokenized = new Tokenize_data();

				rs = dbconn.queryExecute(query.find_segTableName("public", "trajectory_columns"));

				while (rs.next()) {
					segTableName = rs.getString(1);
				}

				while ((data = in.readLine()) != null) {

					if (!isTaxiNum) {
						isTaxiNum = true;

						try {
							rs = dbconn.queryExecute(query.find_TaxiNum(data, "taxi"));

							while (rs.next()) {

								if (rs.getInt(1) == 0) {
									rs1 = dbconn.queryExecute(query.find_MaxId("taxi_id", "taxi"));

									while (rs1.next()) {
										int taxiId = rs1.getInt(1) + 1;
										// System.out.println("Insert record in
										// taxi table");

										dbconn.queryUpdate(query.insert_Taxi(data, "taxi", taxiId));
									}

									rs1 = dbconn.queryExecute(query.get_seqNum("taxi"));

									while (rs1.next()) {

										mpId = rs1.getInt(1);
									}
								} else {

								}
							}
						} catch (Exception e) {
							System.out.println("Exception");
						}
					}

					if (tp_cnt < cnt) {
						tp_cnt++;

						tokenized.tokenize(data);

						if (tp_cnt == 1) {
							start_pt = tokenized.getLatitude() + " " + tokenized.getLongitude();

							start_time = tokenized.getDate_str();
						}

						tpArr += "( tpoint(st_point(" + tokenized.getLatitude() + ", " + tokenized.getLongitude()
								+ "), timestamp '" + tokenized.getDate_str() + "') )";

						ptArr += tokenized.getLatitude() + " " + tokenized.getLongitude();

						if (tp_cnt < cnt) {

							tpArr += ",";

							ptArr += ",";
						}

						end_time = tokenized.getDate_str();

					} else if (tp_cnt >= cnt) {

						segId++;

						next_segId = segId + 1;

						before_segId = segId - 1;

						ptArr += ", " + start_pt;

						dbconn.queryUpdate(query.insert_traj(segTableName, mpId, segId, next_segId, before_segId,
								tp_cnt, query.make_polygon(ptArr), start_time, end_time, query.make_tpseg(tpArr)));

						tp_cnt = 1;

						tokenized.tokenize(data);

						start_pt = tokenized.getLatitude() + " " + tokenized.getLongitude();

						start_time = tokenized.getDate_str();

						tpArr = "( tpoint(st_point(" + tokenized.getLatitude() + ", " + tokenized.getLongitude()
								+ "), timestamp '" + tokenized.getDate_str() + "') )";

						ptArr = tokenized.getLatitude() + " " + tokenized.getLongitude();

						if (tp_cnt < cnt) {

							tpArr += ",";
							ptArr += ",";
						}
					}
				}

				if (tp_cnt < cnt) {
					segId++;

					next_segId = segId + 1;

					before_segId = segId - 1;

					ptArr += start_pt;

					if (tpArr.length() > 0) {
						tpArr = tpArr.substring(0, tpArr.lastIndexOf(','));

						end_time = tokenized.getDate_str();

						dbconn.queryUpdate(query.insert_traj(segTableName, mpId, segId, next_segId, before_segId,
								tp_cnt, query.make_polygon(ptArr), start_time, end_time, query.make_tpseg(tpArr)));
					}
					// System.out.println(query.insert_traj(mpId, segId,
					// next_segId,
					// before_segId, tp_cnt, query.make_polygon(ptArr),
					// tokenized.getDate_str(), tokenized.getDate_str(),
					// query.make_tpseg(tpArr)));
				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		long end = System.currentTimeMillis();

		System.out.println("Total Time : " + (end - start) / 1000.0);
	}

	/*
	 * Insert Data of a file
	 * 
	 */
	public void data_insert(int cnt, String filePath) throws SQLException {

		int segId = 0, next_segId = 0, before_segId = 0, mpId = 0;

		String start_time = "", end_time = "", before_pt = "", before_time = "", present_pt = "", present_time = "";

		Make_Query query = new Make_Query();

		try {
			in = new BufferedReader(new FileReader(filePath));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		String data;

		boolean isTaxiNum = false, insertOK = true;

		File f = new File(filePath);

		long start = System.currentTimeMillis();

		double minx = 0.0;
		double miny = 0.0;
		double maxx = 0.0;
		double maxy = 0.0;

		Geometry[] geomArr;
		Geometry geom, bounding_box = null;
		GeometryFactory fac = new GeometryFactory();

		Envelope env;

		Coordinate c1;
		Point p1;

		int idx = 0;
		int cnt_partition = 0;

		boolean isNextSeg = false;

		try {

			int tp_cnt = 0;

			String tpArr = "", segTableName = "";

			Tokenize_data tokenized = new Tokenize_data();

			rs = dbconn.queryExecute(query.find_segTableName("public", "trajectory_columns"));

			while (rs.next()) {
				segTableName = rs.getString(1);
			}

			rs = dbconn.queryExecute(query.getCnt_partition("static_partition"));

			while (rs.next()) {
				cnt_partition = rs.getInt(1);
			}

			geomArr = new Geometry[cnt_partition];

			rs = dbconn.queryExecute(query.getPartition_Info("static_partition"));

			while (rs.next()) {
				minx = Double.parseDouble(String.format("%.6f", rs.getDouble(1)));
				miny = Double.parseDouble(String.format("%.6f", rs.getDouble(2)));
				maxx = Double.parseDouble(String.format("%.6f", rs.getDouble(3)));
				maxy = Double.parseDouble(String.format("%.6f", rs.getDouble(4)));

				env = new Envelope(minx, maxx, miny, maxy);
				geom = fac.toGeometry(env);
				geomArr[idx] = geom;

				idx++;
			}

			double beforeLati = 0.0, beforeLong = 0.0;

			while ((data = in.readLine()) != null) {

				if (!isTaxiNum) {
					isTaxiNum = true;

					try {
						rs = dbconn.queryExecute(query.find_TaxiNum(data, "taxi"));

						while (rs.next()) {

							if (rs.getInt(1) == 0) {
								rs1 = dbconn.queryExecute(query.find_MaxId("taxi_id", "taxi"));

								while (rs1.next()) {
									int taxiId = rs1.getInt(1) + 1;
									System.out.println("Insert record in taxi table");

									dbconn.queryUpdate(query.insert_Taxi(data, "taxi", taxiId));
								}

								rs1 = dbconn.queryExecute(query.get_seqNum("taxi"));

								while (rs1.next()) {

									mpId = rs1.getInt(1);
								}
							} else {

							}
						}
					} catch (Exception e) {
						System.out.println("Exception");
					}
				}

				tokenized.tokenize(data);

				if (Double.parseDouble(tokenized.getLatitude()) <= 1
						|| Double.parseDouble(tokenized.getLongitude()) <= 1) {
					insertOK = false;
					continue;
				}

				// System.out.println(tokenized.getLatitude());
				// System.out.println(tokenized.getLongitude());

				c1 = new Coordinate(Double.parseDouble(tokenized.getLatitude()),
						Double.parseDouble(tokenized.getLongitude()));

				p1 = fac.createPoint(c1);

				isNextSeg = false;

				for (int i = 0; i < geomArr.length; i++) {
					if (geomArr[i].covers(p1)) {

						// System.out.println(i + " : " +
						// geomArr[i].toString());
						if (bounding_box == null) {
							bounding_box = geomArr[i];
							// System.out.println("null");
						} else if (!bounding_box.equals(geomArr[i])) {
							bounding_box = geomArr[i];

							before_pt = present_pt;
							before_time = present_time;

							isNextSeg = true;
							// System.out.println("Not null");
						} else {
							// System.out.println("etc");
						}
					}
				}

				if (!isNextSeg) {

					if (tp_cnt < cnt - 1) {
						// System.out.println("111");

						tp_cnt++;

						if (tp_cnt == 1) {
							segId++;

							next_segId = segId + 1;

							before_segId = segId - 1;

							start_time = tokenized.getDate_str();

							tpArr = "( tpoint(st_point(" + tokenized.getLatitude() + ", " + tokenized.getLongitude()
									+ "), timestamp '" + tokenized.getDate_str() + "') )";

							beforeLati = Double.parseDouble(tokenized.getLatitude());
							beforeLong = Double.parseDouble(tokenized.getLongitude());
						} else {

							if (Math.abs(beforeLati - Double.parseDouble(tokenized.getLatitude())) > 1
									|| Math.abs(beforeLong - Double.parseDouble(tokenized.getLongitude())) > 1) {
								insertOK = false;
								continue;
							}

							insertOK = true;

							beforeLati = Double.parseDouble(tokenized.getLatitude());
							beforeLong = Double.parseDouble(tokenized.getLongitude());

							tpArr += ",";

							tpArr += "( tpoint(st_point(" + tokenized.getLatitude() + ", " + tokenized.getLongitude()
									+ "), timestamp '" + tokenized.getDate_str() + "') )";
						}

						present_pt = tokenized.getLatitude() + ", " + tokenized.getLongitude();
						present_time = tokenized.getDate_str();

						end_time = tokenized.getDate_str();
					} else if (tp_cnt >= cnt - 1) {
						// System.out.println("222");

						dbconn.queryUpdate(
								query.insert_traj(segTableName, mpId, segId, next_segId, before_segId, tp_cnt,
										query.make_box2d(bounding_box.getEnvelopeInternal().getMinX(),
												bounding_box.getEnvelopeInternal().getMinY(),
												bounding_box.getEnvelopeInternal().getMaxX(),
												bounding_box.getEnvelopeInternal().getMaxY()),
										start_time, end_time, query.make_tpseg(tpArr)));

						// System.out.println(query.insert_traj(mpId, segId,
						// next_segId, before_segId, tp_cnt,
						// query.make_box2d(bounding_box.getEnvelopeInternal().getMinX(),
						// bounding_box.getEnvelopeInternal().getMinY(),
						// bounding_box.getEnvelopeInternal().getMaxX(),
						// bounding_box.getEnvelopeInternal().getMaxY()),
						// start_time, end_time, query.make_tpseg(tpArr)));

						if (Math.abs(beforeLati - Double.parseDouble(tokenized.getLatitude())) > 1
								|| Math.abs(beforeLong - Double.parseDouble(tokenized.getLongitude())) > 1) {
							insertOK = false;
							continue;
						}

						insertOK = true;

						beforeLati = Double.parseDouble(tokenized.getLatitude());
						beforeLong = Double.parseDouble(tokenized.getLongitude());

						tp_cnt = 1;

						segId++;

						next_segId = segId + 1;

						before_segId = segId - 1;

						start_time = tokenized.getDate_str();

						present_pt = tokenized.getLatitude() + ", " + tokenized.getLongitude();
						present_time = tokenized.getDate_str();

						tpArr = "( tpoint(st_point(" + tokenized.getLatitude() + ", " + tokenized.getLongitude()
								+ "), timestamp '" + tokenized.getDate_str() + "') )";
					}
				} else {
					if (tp_cnt < cnt) {
						// System.out.println("333");

						if (Math.abs(beforeLati - Double.parseDouble(tokenized.getLatitude())) > 1
								|| Math.abs(beforeLong - Double.parseDouble(tokenized.getLongitude())) > 1) {
							insertOK = false;
							continue;
						}

						insertOK = true;

						beforeLati = Double.parseDouble(tokenized.getLatitude());
						beforeLong = Double.parseDouble(tokenized.getLongitude());

						tp_cnt++;

						tpArr += ",";

						tpArr += "( tpoint(st_point(" + tokenized.getLatitude() + ", " + tokenized.getLongitude()
								+ "), timestamp '" + tokenized.getDate_str() + "') )";

						end_time = tokenized.getDate_str();

						dbconn.queryUpdate(
								query.insert_traj(segTableName, mpId, segId, next_segId, before_segId, tp_cnt,
										query.make_box2d(bounding_box.getEnvelopeInternal().getMinX(),
												bounding_box.getEnvelopeInternal().getMinY(),
												bounding_box.getEnvelopeInternal().getMaxX(),
												bounding_box.getEnvelopeInternal().getMaxY()),
										start_time, end_time, query.make_tpseg(tpArr)));

						// System.out.println(query.insert_traj(mpId, segId,
						// next_segId, before_segId, tp_cnt,
						// query.make_box2d(bounding_box.getEnvelopeInternal().getMinX(),
						// bounding_box.getEnvelopeInternal().getMinY(),
						// bounding_box.getEnvelopeInternal().getMaxX(),
						// bounding_box.getEnvelopeInternal().getMaxY()),
						// start_time, end_time, query.make_tpseg(tpArr)));

						tp_cnt = 2;

						segId++;

						next_segId = segId + 1;

						before_segId = segId - 1;

						start_time = before_time;

						end_time = tokenized.getDate_str();

						tpArr = "( tpoint(st_point(" + before_pt + "), timestamp '" + before_time
								+ "') ), ( tpoint(st_point(" + tokenized.getLatitude() + ", " + tokenized.getLongitude()
								+ "), timestamp '" + tokenized.getDate_str() + "') )";
					} else {
						// System.out.println("444");

						if (Math.abs(beforeLati - Double.parseDouble(tokenized.getLatitude())) > 1
								|| Math.abs(beforeLong - Double.parseDouble(tokenized.getLongitude())) > 1) {
							insertOK = false;
							continue;
						}

						insertOK = true;

						beforeLati = Double.parseDouble(tokenized.getLatitude());
						beforeLong = Double.parseDouble(tokenized.getLongitude());

						tp_cnt = 1;

						segId++;

						next_segId = segId + 1;

						before_segId = segId - 1;

						start_time = tokenized.getDate_str();

						present_pt = tokenized.getLatitude() + ", " + tokenized.getLongitude();

						tpArr = "( tpoint(st_point(" + tokenized.getLatitude() + ", " + tokenized.getLongitude()
								+ "), timestamp '" + tokenized.getDate_str() + "') )";
					}
				}
			}

			insertOK = true;

			if (f.length() == 0 || Double.parseDouble(tokenized.getLatitude()) <= 1
					|| Double.parseDouble(tokenized.getLongitude()) <= 1) {
				insertOK = false;
			}

			if (tp_cnt < cnt) {
				end_time = tokenized.getDate_str();

				if (insertOK) {
					dbconn.queryUpdate(query.insert_traj(segTableName, mpId, segId, next_segId, before_segId, tp_cnt,
							query.make_box2d(bounding_box.getEnvelopeInternal().getMinX(),
									bounding_box.getEnvelopeInternal().getMinY(),
									bounding_box.getEnvelopeInternal().getMaxX(),
									bounding_box.getEnvelopeInternal().getMaxY()),
							start_time, end_time, query.make_tpseg(tpArr)));
				}

				// System.out.println(query.insert_traj(mpId, segId, next_segId,
				// before_segId, tp_cnt, query.make_box2d(
				// bounding_box.getEnvelopeInternal().getMinX(),
				// bounding_box.getEnvelopeInternal().getMinY(),
				// bounding_box.getEnvelopeInternal().getMaxX(),
				// bounding_box.getEnvelopeInternal().getMaxY()),
				// start_time, end_time, query.make_tpseg(tpArr)));
			}

			// System.out.println(tmp_idx1);
			// System.out.println(tmp_idx2);
			//
			// System.out.println(query.insert_traj(mpId, segId, next_segId,
			// before_segId, tp_cnt,
			// query.make_polygon(ptArr), start_time, end_time,
			// query.make_tpseg(tpArr)));
		} catch (

		IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		long end = System.currentTimeMillis();

		System.out.println("Total Time : " + (end - start) / 1000.0);
	}

	/*
	 * exist table
	 * 
	 */
	public boolean exist_table(String schemeName, String tbName) {

		Make_Query query = new Make_Query();

		boolean bool = true;

		try {
			rs = dbconn.queryExecute(query.is_table(schemeName, tbName));

			while (rs.next()) {
				if (rs.getInt(1) == 0) {
					dbconn.queryUpdate(query.create_trajDataTable(tbName));

					bool = true;
				}
			}
		} catch (Exception e) {
			bool = false;
		}

		return bool;
	}

	/*
	 * insert_mqseqTrajData of a file
	 * 
	 */
	public void insert_mpseqTrajData(int cnt, String filePath) {

		Make_Query query = new Make_Query();

		try {
			in = new BufferedReader(new FileReader(filePath));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		String data;

		boolean isTaxiNum = false, insertOK = true;

		File f = new File(filePath);

		if (f.length() == 0) {
			insertOK = false;
		}

		try {
			int tp_cnt = 0;

			String tpArr = "", ptArr = "", startPt = "";

			Tokenize_data tokenized = new Tokenize_data();

			boolean isStart = true;

			double beforeLati = 0.0, beforeLong = 0.0;

			while ((data = in.readLine()) != null) {

				/*
				 * if (!isTaxiNum) { isTaxiNum = true;
				 * 
				 * try { rs = dbconn.queryExecute(query.find_TaxiNum(data,
				 * "taxi"));
				 * 
				 * while (rs.next()) {
				 * 
				 * if (rs.getInt(1) == 0) { rs1 =
				 * dbconn.queryExecute(query.find_MaxId("taxi_id", "taxi"));
				 * 
				 * while (rs1.next()) { int taxiId = rs1.getInt(1) + 1;
				 * System.out.println("Insert record in taxi table");
				 * 
				 * dbconn.queryUpdate(query.insert_Taxi(data, "taxi", taxiId));
				 * }
				 * 
				 * rs1 = dbconn.queryExecute(query.get_seqNum("taxi"));
				 * 
				 * while (rs1.next()) {
				 * 
				 * mpId = rs1.getInt(1); } } else {
				 * 
				 * } } } catch (Exception e) { System.out.println("Exception");
				 * } }
				 */

				tokenized.tokenize(data);

				if (Double.parseDouble(tokenized.getLatitude()) <= 1
						|| Double.parseDouble(tokenized.getLongitude()) <= 1) {
					insertOK = false;
					continue;
				}

				if (tp_cnt < cnt) {

					if (tp_cnt > 1) {
						if (Math.abs(beforeLati - Double.parseDouble(tokenized.getLatitude())) > 1
								|| Math.abs(beforeLong - Double.parseDouble(tokenized.getLongitude())) > 1) {
							insertOK = false;
							continue;
						}
					}

					insertOK = true;

					if (!isStart) {
						tpArr += ",";
						ptArr += ",";
					}

					isStart = false;

					tp_cnt++;

					tpArr += "( tpoint(st_point(" + tokenized.getLatitude() + ", " + tokenized.getLongitude()
							+ "), timestamp '" + tokenized.getDate_str() + "') )";
					ptArr += tokenized.getLatitude() + " " + tokenized.getLongitude();

					beforeLati = Double.parseDouble(tokenized.getLatitude());
					beforeLong = Double.parseDouble(tokenized.getLongitude());

				} else if (tp_cnt == cnt) {

					// System.out.println(ptArr.split(",").length);
					startPt = ptArr.split(",")[0];

					ptArr += "," + startPt;

					// System.out.println(query.makeQuery_insertMpseqTrajData(tokenized.getOid(),
					// tp_cnt,
					// query.make_polygon(ptArr), query.make_tpseg(tpArr)));

					dbconn.queryUpdate(query.makeQuery_insertMpseqTrajData(tokenized.getOid(), tp_cnt,
							query.make_polygon(ptArr), query.make_tpseg(tpArr)));

					if (Math.abs(beforeLati - Double.parseDouble(tokenized.getLatitude())) > 1
							|| Math.abs(beforeLong - Double.parseDouble(tokenized.getLongitude())) > 1) {
						insertOK = false;
						continue;
					}

					insertOK = true;

					beforeLati = Double.parseDouble(tokenized.getLatitude());
					beforeLong = Double.parseDouble(tokenized.getLongitude());

					tp_cnt = 1;

					tpArr = "( tpoint(st_point(" + tokenized.getLatitude() + ", " + tokenized.getLongitude()
							+ "), timestamp '" + tokenized.getDate_str() + "') )";
					ptArr = tokenized.getLatitude() + " " + tokenized.getLongitude();
				}
			}

			startPt = ptArr.split(",")[0];

			ptArr += "," + startPt;

			if (insertOK) {
				dbconn.queryUpdate(query.makeQuery_insertMpseqTrajData(tokenized.getOid(), tp_cnt,
						query.make_polygon(ptArr), query.make_tpseg(tpArr)));
			}

			// System.out.println(query.makeQuery_insertMpseqTrajData(tokenized.getOid(),
			// tp_cnt,
			// query.make_polygon(ptArr), query.make_tpseg(tpArr)));
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	/*
	 * 
	 */
	// public void insert_files(int cnt, String path) {
	//
	// File f = new File(path);
	//
	// File[] result = new File[1];
	//
	// File[] pathArr = f.listFiles();
	//
	// File tmp_file;
	// String dir_name = "";
	//
	// for (int i = 0; i < pathArr.length; i++) {
	//
	// if (pathArr[i].isDirectory()) {
	// if (pathArr[i].getAbsolutePath().length() != 5) {
	//
	// dir_name = pathArr[i].getName();
	//
	// for (; dir_name.length() < 5;) {
	// dir_name = "0" + dir_name;
	// }
	// tmp_file = new File(pathArr[i].getAbsolutePath());
	// tmp_file.renameTo(new File(pathArr[i].getParent() + "/" + dir_name));
	//
	// } else {
	// tmp_file = new File(pathArr[i].getAbsolutePath());
	// }
	// }
	// }
	//
	// Arrays.sort(pathArr);
	//
	// int total = 0;
	//
	// for (int i = 0; i < pathArr.length; i++) {
	// if (pathArr[i].isDirectory()) {
	// // System.out.println(pathArr[i].getAbsolutePath());
	// total += pathArr[i].list().length;
	// } else {
	// total++;
	// }
	// }
	// // System.out.println(total);
	//
	// result = new File[total];
	//
	// File[] tmpArr;
	// int srcPos = 0;
	//
	// for (int i = 0; i < pathArr.length; i++) {
	// tmpArr = pathArr[i].listFiles();
	//
	// Arrays.sort(tmpArr);
	// for (int j = 0; j < tmpArr.length; j++) {
	// result[srcPos] = tmpArr[j];
	// srcPos++;
	// }
	// }
	//
	// for (int i = 0; i < result.length; i++) {
	// insert_mqseqTrajData(1000, result[i].toString());
	// // System.out.println(i + " : " + result[i]);
	// }
	//
	// // return result;
	// }

	public void insert_files(int cnt, String path, String type) throws SQLException {

		File f = new File(path);

		File[] result = new File[1];

		File[] pathArr = f.listFiles();

		File tmp_file;
		String dir_name = "";

		for (int i = 0; i < pathArr.length; i++) {

			if (pathArr[i].isDirectory()) {
				if (pathArr[i].getAbsolutePath().length() != 5) {

					dir_name = pathArr[i].getName();

					for (; dir_name.length() < 5;) {
						dir_name = "0" + dir_name;
					}
					tmp_file = new File(pathArr[i].getAbsolutePath());
					tmp_file.renameTo(new File(pathArr[i].getParent() + "/" + dir_name));

				} else {
					tmp_file = new File(pathArr[i].getAbsolutePath());
				}
			}
		}

		Arrays.sort(pathArr);

		int total = 0;

		for (int i = 0; i < pathArr.length; i++) {
			if (pathArr[i].isDirectory()) {
				// System.out.println(pathArr[i].getAbsolutePath());
				total += pathArr[i].list().length;
			} else {
				// System.out.println(total + "file: " +
				// pathArr[i].getAbsolutePath());
				total++;
			}
		}
		System.out.println(total);

		result = new File[total];

		File[] tmpArr;
		int srcPos = 0;

		for (int i = 0; i < pathArr.length; i++) {
			if (pathArr[i].isDirectory()) {
				tmpArr = pathArr[i].listFiles();

				Arrays.sort(tmpArr);
				for (int j = 0; j < tmpArr.length; j++) {
					result[srcPos] = tmpArr[j];
					srcPos++;
				}
			} else {
				result[srcPos] = pathArr[i];
				srcPos++;

			}
		}

		if (type.equals("segmentTb")) {
			for (int i = 0; i < result.length; i++) {
				System.out.println((i + 1) + "/" + total + " : " + result[i].toString());
				data_insert(cnt, result[i].toString());
			}
		}

		if (type.equals("subTb")) {
			for (int i = 0; i < result.length; i++) {
				System.out.println((i + 1) + "/" + total + " : " + result[i].toString());
				insert_mpseqTrajData(cnt, result[i].toString());
			}
		}

		// return result;
	}

}
