import csv

def choose_delimiter():
    print("Select CSV delimiter:")
    print("1: ;")
    print("2: ,")
    print("3: |")
    print("4: TAB")

    choice = input("Choice: ").strip()

    if choice == "1":
        return ";"
    if choice == "2":
        return ","
    if choice == "3":
        return "|"
    if choice == "4":
        return "\t"

    print("Invalid choice, defaulting to ';'")
    return ";"


def load_csv(path, delimiter):
    data = {}
    order = []

    with open(path, newline='', encoding="utf-8") as f:
        reader = csv.reader(f, delimiter=delimiter)

        for row in reader:
            if not row:
                continue

            key = row[0]

            data[key] = row
            order.append(key)

    return data, order


def merge_csv(file_a, file_b, delimiter):

    data_a, order_a = load_csv(file_a, delimiter)
    data_b, order_b = load_csv(file_b, delimiter)

    merged = {}
    all_keys = list(dict.fromkeys(order_a + order_b))

    for key in all_keys:

        in_a = key in data_a
        in_b = key in data_b

        if in_a and in_b:

            if data_a[key] == data_b[key]:
                merged[key] = data_a[key]
                continue

            print("\nConflict for:", key)
            print("A:", data_a[key])
            print("B:", data_b[key])

            choice = input("Choose (A/B): ").strip().lower()

            if choice == "b":
                merged[key] = data_b[key]
            else:
                merged[key] = data_a[key]

        elif in_a:
            print("\nOnly in A:", key)
            print(data_a[key])

            choice = input("Add this line? (y/n): ").strip().lower()

            if choice == "y":
                merged[key] = data_a[key]

        elif in_b:
            print("\nOnly in B:", key)
            print(data_b[key])

            choice = input("Add this line? (y/n): ").strip().lower()

            if choice == "y":
                merged[key] = data_b[key]

    return merged


def write_csv(path, data, delimiter):

    with open(path, "w", newline='', encoding="utf-8") as f:
        writer = csv.writer(f, delimiter=delimiter)

        for key in data:
            writer.writerow(data[key])


def main():

    print("CSV Merger Tool\n")

    file_a = input("File A (usually OLD): ")
    file_b = input("File B (usually NEW): ")

    delimiter = choose_delimiter()

    merged = merge_csv(file_a, file_b, delimiter)

    output = input("\nOutput file name: ")

    write_csv(output, merged, delimiter)

    print("\nMerge complete.")


if __name__ == "__main__":
    main()