"""Exact Jaccard join using global token order and length/prefix filtering."""
from collections import Counter, defaultdict
from math import ceil


def exact_jaccard_pairs(sets: dict, threshold: float = 0.9):
    if not 0 < threshold <= 1:
        raise ValueError("threshold must be in (0, 1]")
    frequency = Counter(item for values in sets.values() for item in values)
    rank = {item: i for i, item in enumerate(sorted(frequency, key=lambda x: (frequency[x], x)))}
    postings = defaultdict(list)
    for key in sorted(sets, key=lambda x: (len(sets[x]), x)):
        values = sets[key]
        if not values:
            continue
        ordered = sorted(values, key=rank.__getitem__)
        prefix_size = len(values) - ceil(threshold * len(values) - 1e-12) + 1
        prefix = ordered[:prefix_size]
        candidates = set()
        for item in prefix:
            candidates.update(postings[item])
        for other in sorted(candidates):
            previous = sets[other]
            if len(previous) + 1e-12 < threshold * len(values):
                continue
            intersection = len(values & previous)
            score = intersection / (len(values) + len(previous) - intersection)
            if score + 1e-12 >= threshold:
                yield other, key, score
        for item in prefix:
            postings[item].append(key)
