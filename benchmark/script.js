import http from 'k6/http';
import { check } from 'k6';

export const options = {
  vus: 50,
  duration: '60s',
  summaryTrendStats: ['avg', 'med', 'p(95)', 'p(99)'],
};

export default function () {
  const res = http.get(`${__ENV.TARGET}`);
  check(res, { 'status 200': (r) => r.status === 200 });
}
