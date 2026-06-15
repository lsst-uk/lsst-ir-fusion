import os
from astropy.io import fits

# Base directory containing observation date directories on CSD3 (e.g., 20121022, 20121103, etc.)
base_dir = '/home/ir-sare1/rds/rds-iris-ip005/data/private/VISTA/VIDEO/'
# List to store the paths to CDFS images
cdfs_images = []

# Define the CDFS field boundaries (RA and DEC in degrees)
cdfs_ra_min = 50.7
cdfs_ra_max = 55.5
cdfs_dec_min = -30.50
cdfs_dec_max = -25.92

# Function to check if an image falls within the CDFS coordinates
def is_cdfs_image(fits_file):
    try:
        # Open the FITS file to check the header
        with fits.open(fits_file) as hdulist:
            header = hdulist[0].header
            ra = header.get('RA', None)
            dec = header.get('DEC', None)
            
            # Check if RA and DEC exist and fall within CDFS boundaries
            if ra is not None and dec is not None:
                if cdfs_ra_min <= ra <= cdfs_ra_max and cdfs_dec_min <= dec <= cdfs_dec_max:
                    return True
    except Exception as e:
        print(f"Error reading {fits_file}: {e}")
    return False

# Loop over all subdirectories in the base directory
total_files = 0
for subdir in os.listdir(base_dir):
    obs_dir = os.path.join(base_dir, subdir)
    if os.path.isdir(obs_dir):  # Make sure it's a directory
        # Count the number of files in the directory to provide progress updates
        fits_files = [f for f in os.listdir(obs_dir) if f.endswith('_st.fit')]
        total_files += len(fits_files)

processed_files = 0
# Start processing each subdirectory
for subdir in os.listdir(base_dir):
    obs_dir = os.path.join(base_dir, subdir)
    if os.path.isdir(obs_dir):  # Make sure it's a directory
        # Loop over all FITS files in the subdirectory
        for filename in os.listdir(obs_dir):
            if filename.endswith('_st.fit'):  # Only process files ending with '_st.fit'
                fits_file = os.path.join(obs_dir, filename)
                if is_cdfs_image(fits_file):
                    cdfs_images.append(fits_file)
                
                # Update progress
                processed_files += 1
                if processed_files % 100 == 0:  # Print a progress update every 100 files
                    print(f"Processed {processed_files}/{total_files} files.")

# Output the list of CDFS images
print(f"Found {len(cdfs_images)} CDFS images.")
with open('cdfs_images.txt', 'w') as f:
    for img in cdfs_images:
        f.write(f"{img}\n")

print("CDFS image list saved to cdfs_images.txt.")
