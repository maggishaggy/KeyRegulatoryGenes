###############################################################
#  - ILP Formulation for directed Minimum Dominating Set (MDS)#
#  - Main function to be called#
#  - 2016-01-08#
#  - Copyright: Maryam Nazarieh, Andreas Wiese, Volkhard Helms#
###############################################################

 
def MDS_direct(str,out):
	import csv
	input_file = str
	f=open(str,'r')
	Zreader = csv.reader(f,delimiter='\t')
	g = DiGraph([((u),(v)) for u,v in Zreader],multiedges=True,loops=True)
	f.close()

	# Define the linear program as a minimization problem
	p = MixedIntegerLinearProgram(maximization = False,solver="GLPK")
	b = p.new_variable(binary = True)
	c = p.new_variable(binary = True)
	p.set_objective(sum([b[v] for v in g]) )
	for u in g:
    		p.add_constraint(b[u] + sum([b[v] for v in g.neighbors_in(u)])  >= 1 )
	p.solve()
	b = p.get_values(b)
	m = [v for v,i in b.items() if i]
	print m
	with open(out, 'w') as fp:
		for i in range(len(m)):
			print>> fp,m[i]
	fp.close()
	# Drawing the solution
	#g.show(vertex_colors={"red":m})
	return
if __name__ == '__main__':
    if len(sys.argv) == 3:
		MDS_direct(str=sys.argv[1],out=sys.argv[2])
    else:
        print len(sys.argv)
        sys.exit(1)
	
