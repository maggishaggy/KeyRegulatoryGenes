##########################################################################
#  - ILP Formulation for directed Minimum Connected Dominating Set (MCDS)#
#  - Main function to be called#
#  - 2016-01-08#
#  - Copyright: Maryam Nazarieh, Andreas Wiese, Volkhard Helms#
##########################################################################

def MCDS_direct(component, str, out):
    import csv
    
    # Read from CSV file
    f=open(str,'r')
    Zreader = csv.reader(f,delimiter='\t')
    G = DiGraph([((u),(v)) for u,v in Zreader],multiedges=True,loops=True)
    print "Number of Vertices and Edges in the Network: ", len(G.vertices()),len(G.edges())    
    f.close()
    #G.show()
    
    #Variable Definition
    x = len(G.connected_components())
    print "Number of Connected Components in the network: ",x
    
    if  component == 'LCC':
    	cc = G.connected_components_subgraphs()
    
    elif component == 'LSCC':
	    cc = G.strongly_connected_components_subgraphs()
	    
    else:
	    cc = G.connected_components_subgraphs()	
	    
    
    max = 0
    le_max = 0
    for i in range(len(cc)):
        if(len(cc[i].vertices()) > le_max):
            le_max = len(cc[i].vertices())
            max = i
    g = cc[max]
    
    if  component == 'LCC':
        print "Number of Vertices and Edges in the Largest Connected Components of the Network: ", len(g.vertices()),len(g.edges())
    elif component == 'LSCC':
        print "Number of Vertices and Edges in the Largest Strongly Connected Components of the Network: ", len(g.vertices()),len(g.edges())
    
    #Creating ILP
    p = MixedIntegerLinearProgram(maximization = False,solver="GLPK")
    b = p.new_variable(binary=True, nonnegative=True)
    c = p.new_variable(binary=True, nonnegative=True)
    
    #Objective Function for MCDS
    p.set_objective(sum([b[u] for u in g]) )
    
    
    #print "add domninator constraints"
    #Constraint 1: Guarantees the set is dominators
    for u in g:
        #p.add_constraint(((b[u] + sum([b[v] for v in g.neighbors(u)])) - sum([c[Set(e)] for e in g_u.edges(labels = False)])) >= 1)
        p.add_constraint(b[u] + sum([b[v] for v in g.neighbors_in(u)]) >= 1 )

    
    #print "add constraints for number of edges"
    #Constraint 2: Guarantees that the number of selected edges is exactly one unity less than the number of vertics in a connected dominating set.
    p.add_constraint(sum([c[Set(e)] for e in g.edges(labels = False)]) == sum([b[u] for u in g.vertices()])-1)
    
    #print "add constraints for edges"
    #valid inequality
    for e in g.edges(labels = False):
        for v in Set(e):
            #p.add_constraint(c[Set(e)] <= b[u])
            p.add_constraint(c[Set(e)] <= b[v])
            #print e    

    
    #Constraint 3: Guarantees that the selected edges imply a tree. A valid inequality has been added at this constraint.
    #print "solving IP"
    p.solve()
    #print "IP solved"
    #p.show()
    #S = Subsets(g.vertices())
    #print "Total number of sets is: ", S.cardinality()
    while True:
        b_sol = p.get_values(b)
        c_sol = p.get_values(c)
        #print "b_sol, c_sol: ",b_sol,c_sol 
        vertices = [v for v, i in b_sol.items() if i == 1]
        edges = [v for v, i in c_sol.items() if i == 1]
        #print "vertice, edges: ", vertices,edges
        g_test = g.subgraph(vertices = vertices)
        if g_test.is_connected():
                print "connected"
                break
        else:
            #print "not connected"
            ss = g_test.connected_components_subgraphs()
            n = g_test.connected_components_number()
            print "Number of connected components in this iteration: ",n
            for s in ss:
                VS = s.vertices()
                ES = s.edges(labels = False)
                #print VS, ES
                if(len(VS) > 1):
                    for v in VS:
                        p.add_constraint(sum([c[Set(e)] for e in ES]) <= sum([b[u] for u in VS if u != v]))
                        #break
            p.solve()
        
    
    #Solve the Integer Linear programming
    b = p.get_values(b)
    m = [v for v in g if b[v]]
    print "mcds",m

    print len(m)
    # Drawing the solution
    #g.show(vertex_colors={"red":m})
    with open(out, 'w') as fp:
        for i in range(len(m)):
            print>> fp,m[i]
    fp.close()
    return
if __name__ == '__main__':
    if len(sys.argv) == 4:
        MCDS_direct(component = sys.argv[1],str=sys.argv[2],out=sys.argv[3])
    else:
        print len(sys.argv)
        sys.exit(1)
    

    
