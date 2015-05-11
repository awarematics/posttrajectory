
#include <geos/geom/Point.h>
#include <geos/geom/Coordinate.h>
#include <geos/geom/CoordinateArraySequence.h>
#include <geos/geom/Dimension.h>
#include <geos/geom/Geometry.h>
#include <geos/geom/GeometryFactory.h>

#include <iostream>
#include <vector>

using namespace std;

public class MPoint : MObject
{
protected:
	vector<Point> moVector;
	vector<Instant> timeVector;

private:
	double LocalGetSlope(Coordinate p1, Coordinate p2);
	bool LocalGetCoefficient(double x1, double y1, double x2, double y2,
		double x3, double y3, double a, double b, double c);
	Coordinate LocalGetPoint(Instant instantTime, int FromIndex);
	Coordinate LocalGetPoint(int index);
	bool LocalGetIntersects(Object mobject, Vector interObjects);
	void LocalIntersectsP(MPoint mpoint, Vector interObjects);
	void LocalIntersectsL(MLineString mlinestring, Vector interObjects);
	void LocalIntersectsPG(MPolygon mpolygon, Vector interObjects);
	void LocalMakeIntersects(int index, Vector projectIntersectionList,
		Vector interObjects);
	void LocalMakeMBool(MBool mbool, Object comTime, Object otherObject,
		Vector interObjects, int checkRelation);
	Vector LocalGetState(Coordinate sp, Coordinate ep, MObject otherTrajectory);
	Vector LocalGetStateL(Coordinate sp, Coordinate ep,
		LineString otherTrajectory);
	Vector LocalGetStateP(Coordinate sp, Coordinate ep,
		LineString otherTrajectory);
	bool LocalIsFrontExtStateP(int k, Vector intersections,
		bool earlierStatePoint);
	bool LocalIsFrontExtStateL(int k, Vector intersections,
		bool earlierStatePoint);
public:
	MPoint();
	MPoint(MovingFunctionType functionType);

	Point getObject(int index);
	Instant getTime(int index);
	MDouble mSpeed();
	MDouble mAcceleration();
	MDouble direction();
	long getDimension();
	bool isEmpty();
	bool isSimple();
	MObject envelope();
	MObject clone();
	int getSRID();
	void setSRID(int value);
	bool equals(Object obj);
	MBool mEquals(MObject other);
	MBool touches(MObject other);
	MBool withins(MObject other);
	MBool mDisjoints(MObject other);
	MBool mCrosses(MObject other);
	MBool overlaps(MObject other);
	MBool Intersects(MObject other);
	bool enters(MObject other);
	bool leaves(MObject other);
	bool passes(MObject other);
	bool Insides(MObject other);
	bool Meets(MObject other);
	MDouble mDistance(MObject other);
	MObject boundary();
	MObject convexHull(MObject convexhull);
	MObject buffer(double distance);
	MObject union(MObject other);
	MObject difference(MObject other);
	MObject Intersection(MObject other);
	MObject symmetricDifference(MObject other);
	int getCount();
	int add(Instant instant, Object dataValue);
	int index(TObject instantObject);
	MPoint subSequence(int fromIndex, int toIndex);
	MPoint subSequence(Instant fromTime, Instant toTime);
	TObject min();
	TObject min(int columnIndex);
	TObject max();
	TObject max(int columnIndex);
	Point snapshot(Instant t);
	Point snapshot(Instant t, MFunction mFunction);
	MPoint slice(Interval interval);
	MPoint slice(Instant fromTime, Instant toTime);
	ITemporal snapshotByValue(Object dataObject);
	ITemporal snapshotByValue(int columnIndex, Object dataObject);
	ITemporal sliceByValue(Object fromValue, Object toValue);
	ITemporal sliceByValue(int columnIndex, Object fromValue, Object toValue);
	LineString project();
	byte[] exportToWKB();
	String exportToWKT();
	bool ImportFromWKB(byte[] buffer, int spRef);
	bool ImportFromWKT(String buffer, int spRef);
	long WKBSize();	
	MObject getClone();

};

MPoint::MPoint() 
{
	vector<Point> moVector;
	vector<Instant> timeVector;
}

MPoint::MPoint(MovingFunctionType functionType) 
{
	vector<Point> moVector;
	vector<Instant> timeVector;
}

Point MPoint::getObject(int index) 
{
	if (index >= moVector.size() || index < 0)
		return NULL;

	return moVector.at(index);
}

Instant MPoint::getTime(int index) 
{
	if (index >= timeVector.size() || index < 0)
		return NULL;

	return timeVector.at(index);
}

MDouble MPoint::mSpeed() 
{
	// TODO
	return NULL:
}

MDouble MPoint::mAcceleration() 
{
	double acc = 0;	// MPoint는 linear하게 움직인다고 가정한다. 따라서 가속도는 0이다.
	MDouble mAcc = new MDouble();

	if (isEmpty())
		return mAcc;

	mAcc.add(timeVector.begin(), acc);
	if (timeVector.size() > 1)
		mAcc.add(timeVector.at(timeVector.size() - 1), acc);

	return mAcc;
}

MDouble MPoint::direction() 
{
	MDouble mDirection = new MDouble(MovingFunctionType.STEPWISE);
	double dir = 0;

	
	return NULL;
}

long MPoint::getDimension() 
{
	// TODO
	return 0;
}

bool MPoint::isEmpty() 
{
	if (moVector.size() == 0)
		return true;

	return false;
}

bool MPoint::isSimple() 
{
	// TODO
	return true;
}

MObject MPoint::envelope() 
{
	// TODO
	return NULL;
}

MObject MPoint::clone()
{
	return NULL;
}

int MPoint::getSRID()
{
	return srid;
}

void MPoint::setSRID(int value)
{
	srid = value;
}

bool MPoint::equals(Object obj)
{
	bool b = true;

	if (obj instanceof MPoint)
	{
		MPoint other = (MPoint)obj;

		if (this.moList.size() == other.getCount())
		{
			int size = this.moList.size();

			for (int i = 0; i < size; i++)
			{
				if (!this.getObject(i).equals(other.getObject(i)))
				{
					b = false;
					break;
				}
				if (this.getTime(i).getMillis() != other.getTime(i).getMillis())
				{
					b = false;
					break;
				}
			}
		}
	}
	else
		b = false;

	return b;
}

MBool MPoint::mEquals(MObject other)
{
	MBool isEquals = new MBool();

	
	return isEquals;
}

MBool MPoint::touches(MObject other)
{
	
	return NULL;
}

MBool MPoint::withins(MObject other)
{
	MBool isWithins = NULL;

	
	return NULL;
}

MBool MPoint::mDisjoints(MObject other)
{
	MBool isDisjoints = NULL;
	

	return isDisjoints;
}

MBool MPoint::mCrosses(MObject other)
{
	MBool isCrosses = NULL;
	
	return NULL;
}

MBool MPoint::overlaps(MObject other)
{
	MBool isOverlaps = NULL;

	return NULL;
}

MBool MPoint::Intersects(MObject other)
{
	MBool isIntersects = NULL;

	
	return NULL;
}

bool MPoint::enters(MObject other)
{
	bool isEnters = false;


	return false;
}

bool MPoint::leaves(MObject other)
{
	bool isLeaves = false;

	return false;
}

bool MPoint::passes(MObject other)
{
	bool isPasses = false;


	return false;
}

bool MPoint::Insides(MObject other)
{
	bool isInsides = false;

	return false;

}

bool MPoint::Meets(MObject other)
{
	bool isMeets = false;
	
	return false;
}

MDouble MPoint::mDistance(MObject other)
{
	MDouble distance = NULL;
	
	return NULL;
}

MObject MPoint::boundary()
{
	// TODO
	return NULL;
}

MObject MPoint::convexHull(MObject convexhull)
{
	// TODO
	return NULL;
}

MObject MPoint::buffer(double distance)
{
	MObject buffer = NULL;

	return NULL;
}

MObject MPoint::union(MObject other)
{
	MObject union = NULL;

	return NULL;
}

MObject MPoint::difference(MObject other)
{
	MObject difference = NULL;

	return NULL;
}

MObject MPoint::Intersection(MObject other)
{
	MObject intersection = NULL;

	return NULL;
}

MObject MPoint::symmetricDifference(MObject other)
{

	MObject symmentricDifference = NULL;

	return NULL;
}

int MPoint::getCount()
{	
	return moList.size();
}

int MPoint::add(Instant instant, Object dataValue)
{
	moList.add((Point)dataValue);
	timeList.add(instant);

	return (moList.size() - 1);
}

int MPoint::index(TObject instantObject)
{
	int size = timeList.size();
	for (int i = 0; i < size; i++)
		if (timeList.get(i).equals(instantObject))
			return i;
	return -1;	
}

MPoint MPoint::subSequence(int fromIndex, int toIndex)
{
	// TODO
	return NULL;
}

MPoint MPoint::subSequence(Instant fromTime, Instant toTime)
{
	// TODO
	return NULL;
}

TObject MPoint::min()
{
	// TODO
	return NULL;
}

TObject MPoint::min(int columnIndex)
{
	// TODO
	return NULL;
}

TObject MPoint::max()
{
	// TODO
	return NULL;
}

TObject MPoint::max(int columnIndex)
{
	// TODO
	return NULL;
}

Point MPoint::snapshot(Instant t)
{
	MFunction mFunction = new MFunction(MovingFunctionType.LINEAR);
	return snapshot(t, mFunction);
}

Point MPoint::snapshot(Instant t, MFunction mFunction)
{

	double newX, newY;

	if (!isOnLifeTime(t))
		return NULL;

	int searchIndex = Collections.binarySearch(timeList, t);
	if (searchIndex >= 0)
	{
		Point p = NULL;

		p = moList.get(searchIndex);
		return (Point)p.clone();
	}

	// if the point of instant t is unknown 
	int index = searchIndex*-1 - 1;

	Point fromPoint = moList.get(index - 1);
	Point toPoint = moList.get(index);
	Instant fromTime = timeList.get(index - 1);
	Instant toTime = timeList.get(index);

	newX = mFunction.at(fromPoint.getX(), toPoint.getX(), fromTime, toTime, t);
	newY = mFunction.at(fromPoint.getY(), toPoint.getY(), fromTime, toTime, t);

	return GeometryFactory.createPointFromInternalCoord(new Coordinate(newX, newY), fromPoint);
}

MPoint MPoint::slice(Interval interval)
{
	Instant fromTime = new Instant(interval.getStartMillis());
	Instant toTime = new Instant(interval.getEndMillis());

	return slice(fromTime, toTime);
}

MPoint MPoint::slice(Instant fromTime, Instant toTime)
{
	MPoint resultMPoint = new MPoint();
	vector<Instant> eventTimes = NULL;
	Point snapPoint = NULL;

	eventTimes = super.getEventTimes(fromTime, toTime);

	for (Instant t : eventTimes)
	{
		snapPoint = snapshot(t);
		resultMPoint.add(t, snapPoint);
	}

	return resultMPoint;
}

ITemporal MPoint::snapshotByValue(Object dataObject)
{
	// TODO	
	return NULL;
}

ITemporal MPoint::snapshotByValue(int columnIndex, Object dataObject)
{
	// TODO
	return NULL;
}

ITemporal MPoint::sliceByValue(Object fromValue, Object toValue)
{
	// TODO
	return NULL;
}

ITemporal MPoint::sliceByValue(int columnIndex, Object fromValue, Object toValue)
{
	// TODO
	return NULL;
}

LineString MPoint::project()
{
	GeometryFactory factory = new GeometryFactory();
	LineString projected = NULL;
	Coordinate[] coords = NULL;

	coords = new Coordinate[moList.size()];
	for (int i = 0; i < moList.size(); i++)
		coords[i] = moList.get(i).getCoordinate();

	projected = factory.createLineString(coords);

	return projected;
}

byte[] MPoint::exportToWKB()
{
	// TODO
	return NULL;
}

String MPoint::exportToWKT()
{
	// TODO
	return NULL;
}

bool MPoint::ImportFromWKB(byte[] buffer, int spRef)
{
	// TODO
	return true;
}

bool MPoint::ImportFromWKT(String buffer, int spRef)
{
	// TODO
	return true;
}

long MPoint::WKBSize()
{
	// TODO
	return 0;
}


double MPoint::LocalGetSlope(Coordinate p1, Coordinate p2)
{
	return (p2.Y - p1.Y) / (p2.X - p1.X);
}


bool MPoint::LocalGetCoefficient(double x1, double y1, double x2, double y2,
	double x3, double y3, double a, double b, double c)
{
	double x1x2 = x1 - x2;
	double x2x3 = x2 - x3;
	double y1y2 = y1 - y2;
	double y2y3 = y2 - y3;
	double x1x1x2x2 = (x1 * x1) - (x2 * x2);
	double x2x2x3x3 = (x2 * x2) - (x3 * x3);

	a = ((x2x3 * y1y2) - (x1x2 * y2y3)) / ((x2x3 * x1x1x2x2) - (x1x2 * x2x2x3x3));
	b = (y1y2 - a * x1x1x2x2) / x1x2;
	c = y1 - a * x1 * x1 - b * x1;
	return true;
}

Coordinate MPoint::LocalGetPoint(Instant instantTime, int FromIndex)
{
	// TODO	
	return NULL;
}

Coordinate MPoint::LocalGetPoint(int index)
{
	// TODO
	return NULL;
}

bool MPoint::LocalGetIntersects(Object mobject, vector interObjects)
{
	// TODO
	return false;
}

void MPoint::LocalIntersectsP(MPoint mpoint, vector interObjects)
{
	// TODO
}

void MPoint::LocalIntersectsL(MLineString mlinestring, vector interObjects)
{
	// TODO
}

void MPoint::LocalIntersectsPG(MPolygon mpolygon, vector interObjects)
{
	// TODO
}

void MPoint::LocalMakeIntersects(int index, vector projectIntersectionList,
	vector interObjects)
{
	// TODO
}

void MPoint::LocalMakeMBool(MBool mbool, Object comTime, Object otherObject,
	vector interObjects, int checkRelation)
{
	// TODO
}

vector MPoint::LocalGetState(Coordinate sp, Coordinate ep, MObject otherTrajectory)
{
	// TODO
	return NULL;
}

vector MPoint::LocalGetStateL(Coordinate sp, Coordinate ep,
	LineString otherTrajectory)
{
	// TODO
	return NULL;
}

vector MPoint::LocalGetStateP(Coordinate sp, Coordinate ep,
	LineString otherTrajectory)
{
	// TODO
	return NULL;
}


bool MPoint::LocalIsFrontExtStateP(int k, vector intersections,
	bool earlierStatePoint)
{
	// TODO
	return false;
}


bool MPoint::LocalIsFrontExtStateL(int k, vector intersections,
	bool earlierStatePoint)
{
	// TODO
	return false;
}

MObject MPoint::getClone()
{
	// TODO 
	return NULL;
}