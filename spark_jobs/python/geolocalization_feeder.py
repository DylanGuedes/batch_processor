from interscity_client import platform
from random import random
import math

CAPABILITY = "local_casas"

def rand_cluster(n,c,r):
    """returns n random points in disk of radius r centered at c"""
    x,y = c
    points = []
    for i in range(n):
        theta = 2*math.pi*random()
        s = r*random()
        points.append((x+s*math.cos(theta), y+s*math.sin(theta)))
    return points
def rand_clusters(k,n,r,a,b,c,d):
    """
    return k clusters of n points each in random disks of radius r
    where the centers of the disk are chosen randomly in [a,b]x[c,d]
    """
    clusters = []
    for _ in range(k):
        x = a + (b-a)*random()
        y = c + (d-c)*random()
        clusters.extend(rand_cluster(n,(x,y),r))
    return clusters


clusters = rand_clusters(4,50,0.3,0,1,0,1)
conn = platform.connection()
conn.create_capability("local_casas", "localicazao de casas", "sensor")
houses = platform.resource_builder(connection=conn, capability="local_casas", uniq_key="id")
for house_id in range(1, 199):
    (lat, lon) = clusters[house_id]
    houses.register(str(house_id), "House {0} geolocalization".format(house_id), ["local_casas"])
    houses.send_data(str(house_id), {"lat": lat, "lon": lon})
