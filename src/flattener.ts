export function flattenObject(obj: any, parent: string = '', res: any = {}): any {
    for (let key in obj) {
        let propName = parent ? `${parent}.${key}` : key;
        if (typeof obj[key] === 'object') {
            flattenObject(obj[key], propName, res);
        } else {
            res[propName] = obj[key];
        }
    }
    return res;
}