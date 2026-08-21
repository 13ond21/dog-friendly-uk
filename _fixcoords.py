import csv

FIX = {
    "South West Coast Path: Portreath to St Ives": (50.257, -5.304),
    "Derwentwater Shore Path": (54.605, -3.135),
    "Cleveland Way: Robin Hood's Bay to Whitby": (54.438, -0.618),
    "Ladybower Reservoir Shore": (53.385, -1.685),
    "The Wild Boar": (54.362, -2.802),
    "The Mortal Man": (54.449, -2.918),
    "Norfolk Coast Path: Holkham to Wells": (52.970, 0.806),
    "Cotswold Way: Dovers Hill to Broadway Tower": (52.080, -1.820),
    "Inch Beach": (52.082, -10.118),
    "Torr Head Coastal Walk": (55.199, -6.220),
    "Dollymount Strand (Bull Island)": (53.370, -6.170),
    "Castle Archdale Country Park": (54.470, -7.700),
    "Murder Hole Beach": (55.190, -7.840),
    "Coumeenoole Beach": (52.108, -10.442),
    "Barleycove Beach": (51.472, -9.772),
    "Sheepleas Nature Reserve": (51.272, -0.430),
    "The Look Out (Swinley)": (51.382, -0.731),
    "Craigvinean Forest": (56.500, -3.600),
    "Steall Falls": (56.760, -5.000),
    "Lough Boora Discovery Park": (53.250, -7.600),
    "Knockma Wood": (53.500, -8.850),
    "Tra na Rossan": (55.050, -8.280),
    "White Strand Caherdaniel": (51.750, -10.120),
    "Chapman's Pool": (50.590, -2.000),
    "Coniston Water Shore": (54.360, -3.070),
    "Loch Tay Shore": (56.460, -4.060),
    "Cromdale Hills": (57.280, -3.630),
    "Killahoey Beach": (55.190, -7.960),
    "Five Fingers Strand": (55.330, -7.250),
    "Traigh an Bhinn": (55.150, -7.800),
    "Langdale Pikes": (54.440, -3.110),
    "White Strand (Kerry)": (51.770, -10.120),
    "Tebay Services Toilets": (54.430, -2.590),
    "Bute Park Toilets": (51.480, -3.180),
    "Inch Beach Toilets": (52.082, -10.118),
    "Hengistbury Toilets": (50.720, -1.750),
}

with open("dog-friendly-uk-listings.csv", encoding="utf-8", newline="") as f:
    rows = list(csv.reader(f))

n = 0
for r in rows[1:]:
    if len(r) >= 16 and not r[14] and r[1] in FIX:
        r[14], r[15] = f"{FIX[r[1]][0]:.5f}", f"{FIX[r[1]][1]:.5f}"
        n += 1

with open("dog-friendly-uk-listings.csv", "w", encoding="utf-8", newline="") as f:
    csv.writer(f).writerows(rows)

print("fixed:", n)
