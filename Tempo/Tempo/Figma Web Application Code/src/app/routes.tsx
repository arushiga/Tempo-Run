import { createBrowserRouter } from 'react-router';
import Home from './screens/Home';
import Calendar from './screens/Calendar';
import Record from './screens/Record';
import ActivityNew from './screens/ActivityNew';
import Profile from './screens/Profile';
import Login from './screens/Login';
import SignUp from './screens/SignUp';

export const router = createBrowserRouter([
  {
    path: '/login',
    Component: Login,
  },
  {
    path: '/signup',
    Component: SignUp,
  },
  {
    path: '/',
    Component: Home,
  },
  {
    path: '/calendar',
    Component: Calendar,
  },
  {
    path: '/record',
    Component: Record,
  },
  {
    path: '/activity',
    Component: ActivityNew,
  },
  {
    path: '/profile',
    Component: Profile,
  },
]);
