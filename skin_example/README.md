# Skiner for 'W  ' elements
The code adds boundary elements in surfaces with 'W  ' boundary conditions.

1. increase the element number in SIZE counting for the elements that the code adds
2. **RUN THE CODE IN SERIAL**
nek <case_name>

3. Create the final  *.rea file by running:

 cat toprea newrea.out botrea > newrea.rea

