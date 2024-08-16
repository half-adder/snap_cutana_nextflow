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

samples = channel.fromPath(params.reads)

epitopes = channel.from(barcodes.keySet())
barcode_alpha_idx = channel.from('A', 'B')

barcode_tuples = samples.combine(epitopes).combine(barcode_alpha_idx)

process countBarcodeReads {
    input:
    tuple path(sample), val(epitope), val(alpha_idx)

    output:
    path('barcode_counts.txt')

    script:
    """
    count=\$(grep -c "${barcodes[epitope][alpha_idx]}" ${sample} || true)

    echo ${sample}, ${epitope}, ${alpha_idx}, \$count > barcode_counts.txt
    """
}

process plotHeatMap {
    publishDir 'results', mode: 'copy'

    input: path barcode_counts
    output: tuple path('heatmap.png'), path('heatmap.pdf')

    script:
    """
    plot_heatmap.R
    """
}

workflow {
    counts = countBarcodeReads(barcode_tuples).collectFile(name: 'barcode_counts.txt', newLine: false, sort: true, storeDir: 'results')
    heatmap = plotHeatMap(counts)
}