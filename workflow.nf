barcodes = [
    'Unmodified': ['A': 'TTCGCGCGTAACGACGTACCGT', 'B': 'CGCGATACGACCGCGTTACGCG'],
    'H3K4me1': ['A': 'CGACGTTAACGCGTTTCGTACG', 'B': 'CGCGACTATCGCGCGTAACGCG'],
    'H3K4me2': ['A': 'CCGTACGTCGTGTCGAACGACG', 'B': 'CGATACGCGTTGGTACGCGTAA'],
    'H3K4me3': ['A': 'TAGTTCGCGACACCGTTCGTCG', 'B': 'TCGACGCGTAAACGGTACGTCG'],
    'H3K9me1': ['A': 'TTATCGCGTCGCGACGGACGTA', 'B': 'CGATCGTACGATAGCGTACCGA'],
    'H3K9me2': ['A': 'CGCATATCGCGTCGTACGACCG', 'B': 'ACGTTCGACCGCGGTCGTACGA'],
    'H3K9me3': ['A': 'ACGATTCGACGATCGTCGACGA', 'B': 'CGATAGTCGCGTCGCACGATCG'],
    'H3K27me1': ['A': 'CGCCGATTACGTGTCGCGCGTA', 'B': 'ATCGTACCGCGCGTATCGGTCG'],
    'H3K27me2': ['A': 'CGTTCGAACGTTCGTCGACGAT', 'B': 'TCGCGATTACGATGTCGCGCGA'],
    'H3K27me3': ['A': 'ACGCGAATCGTCGACGCGTATA', 'B': 'CGCGATATCACTCGACGCGATA'],
    'H3K36me1': ['A': 'CGCGAAATTCGTATACGCGTCG', 'B': 'CGCGATCGGTATCGGTACGCGC'],
    'H3K36me2': ['A': 'GTGATATCGCGTTAACGTCGCG', 'B': 'TATCGCGCGAAACGACCGTTCG'],
    'H3K36me3': ['A': 'CCGCGCGTAATGCGCGACGTTA', 'B': 'CCGCGATACGACTCGTTCGTCG'],
    'H4K20me1': ['A': 'GTCGCGAACTATCGTCGATTCG', 'B': 'CCGCGCGTATAGTCCGAGCGTA'],
    'H4K20me2': ['A': 'CGATACGCCGATCGATCGTCGG', 'B': 'CCGCGCGATAAGACGCGTAACG'],
    'H4K20me3': ['A': 'CGATTCGACGGTCGCGACCGTA', 'B': 'TTTCGACGCGTCGATTCGGCGA']
]

samples = channel.fromPath('../data/fastq/unzip/*.fastq')
epitopes = channel.from(barcodes.keySet())
barcode_alpha_idx = channel.from('A', 'B')

barcode_tuples = samples.combine(epitopes).combine(barcode_alpha_idx)

process countBarcodeReads {
    input:
    tuple path(sample_read), val(epitope), val(alpha_idx)

    output:
    path('barcode_counts.txt')
    // tuple val(epitope), val(alpha_idx), path('count'), emit: barcodeReadCounts

    script:
    """
    count=\$(grep -c "${barcodes[epitope][alpha_idx]}" ${sample_read} || echo 0)
    echo ${sample_read}, ${epitope}, ${alpha_idx}, \$count > barcode_counts.txt
    """
}

workflow {
    counts = countBarcodeReads(barcode_tuples).collectFile(name: 'barcode_counts.txt', newLine: false, sort: true, storeDir: 'results')
}