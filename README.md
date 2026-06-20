# Parallel graph algorithms

<img alt="Screenshot From 2026-06-20 18-25-23" src="https://github.com/user-attachments/assets/7f556008-8002-47f7-b89a-61e708b7d9dd" />


### Generate a random sparse graph with a million vertices and ~300 million edges in half a seconds

```
unsigned int seed = time(NULL);
unsigned int n_vertices = 1000000;
unsigned int edge_probability = 0.0005;
// Coordinate graph representation
auto d_graph = pgra::device_graph_coo::create_random(seed, n_vertices, edge_probability);
```

### Export to CSV

```
pgra::host_graph_coo h_graph = d_graph; // copy data from GPU to RAM
h_graph.to_csv("graph.csv");
```

### Available graph representations
- Matrix: `{device|host}_graph_matrix`
- Compressed Sparse Raw: `{device|host}_graph_csr`
- Coordinates: `{device|host}_graph_coo`