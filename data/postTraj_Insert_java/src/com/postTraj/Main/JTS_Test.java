package com.postTraj.Main;

import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.Envelope;
import com.vividsolutions.jts.geom.Geometry;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.Point;

public class JTS_Test {

	public static void main(String[] args) {
		// TODO Auto-generated method stub

		GeometryFactory fac = new GeometryFactory();

	    Geometry geom1, geom2;
	    
	    double minx = 116.658058;
	    double miny = 39.846651;
	    double maxx = 116.770831;
	    double maxy = 39.932358;
	    
	    double minx2 = 116.658058;
	    double miny2 = 39.846651;
	    double maxx2 = 116.770831;
	    double maxy2 = 39.9323581;

	    Envelope env = new Envelope(minx, maxx, miny, maxy);
	    geom1 = fac.toGeometry(env);
	    
	    Envelope env2 = new Envelope(minx2, maxx2, miny2, maxy2);
	    geom2 = fac.toGeometry(env2);
	    
	    System.out.println(geom1.equals(geom2));
	    
	    Coordinate c1 = new Coordinate(minx, miny);
	    
	    Point p1 = fac.createPoint(c1);
	    
	    System.out.println(geom1.getEnvelopeInternal());
	    System.out.println(geom1.contains(p1));
	    System.out.println(geom1.coveredBy(p1));
	    
	    System.out.println(geom1.toString());
	    System.out.println(p1.toString());
	}

}