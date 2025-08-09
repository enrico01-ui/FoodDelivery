<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Menu;

class MenuController extends Controller
{
    public function index()
    {
        $menu = Menu::with('restaurant')->get();

        return response()->json($menu);
    }

    public function store(Request $request)
    {
        $request->validate([
            'restaurant_id' => 'required|string|exists:restaurants,id',
            'name' => 'required|string',
            'type' => 'required|string',
            'description' => 'required|string',
            'price' => 'required|numeric',
            'image_url' => 'required|string'
        ]);

        $menu = Menu::create([
            'restaurant_id' => $request->restaurant_id,
            'name' => $request->name,
            'type' => $request->type,
            'description' => $request->description,
            'price' => $request->price,
            'image_url' => $request->image_url
        ]);

        return response()->json([
            'message' => "Menu Created Successfully",
            'data' => $menu
        ]);
    }

    public function show(Request $request)
    {
        $request->validate([
            'restaurant_id' => 'required|string',
            'name' => 'required|string',
        ]);

        $menu = Menu::where('restaurant_id', 'like', '%' . $request->restaurant_id . '%')
                    ->where('name', 'like', '%' . $request->name . '%')
                    ->first();
        
        if($menu){
            return response()->json([
                'message' => "Menu Found",
                'data' => $menu
            ]);
        }else{
            return response()->json(
                [
                    "Menu Not Found",
                    403
                ]
            );
        }
    }

    public function update(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'type' => 'required|string',
            'description' => 'required|string',
            'price' => 'required|numeric',
            'image_url' => 'required|string'
        ]);

        $menu = Menu::where('name', 'like', '%' . $request->name . '%')
                    ->where('type', 'like', '%' . $request->type . '%')
                    ->where('description', 'like', '%' . $request->description . '%')
                    ->where('price', 'like', '%' . $request->price . '%')
                    ->where('image_url', 'like', '%' . $request->image_url . '%')
                    ->first();
        
        if($menu){
            $menu->update([
                'name' => $request->name,
                'type' => $request->type,
                'description' => $request->description,
                'price' => $request->price,
                'image_url' => $request->image_url
            ]);
            return response()->json([
                'message' => 'Menu Updated Successfully',
                'data' => $menu
            ]);
        }else{
            return response()->json([
                'message' => 'Menu not Found'
            ]);
        }
    }

    public function destroy(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'description' => 'required|string',
            'price' => 'required|numeric',
            'image_url' => 'required|string'
        ]);

        $menu = Menu::where('name', 'like', '%' . $request->name . '%')
                    ->where('description', 'like', '%' . $request->description . '%')
                    ->where('price', 'like', '%' . $request->price . '%')
                    ->where('image_url', 'like', '%' . $request->image_url . '%')
                    ->first();

        if($menu) {
            $menu->delete();
            return response()->json([
                'message' => 'Menu deleted successfully'
            ], 200);
        } else {
            return response()->json([
                'message' => 'Menu not found'
            ], 403);
        }

        
    }

    public function showAll(Request $request)
    {
        $request->validate([
            'restaurant_id' => 'required|string',
        ]);

        $menu = Menu::where('restaurant_id', 'like', '%' . $request->restaurant_id . '%')->get();

        if (!$menu) {
            return response()->json([
                'message' => 'Menu not found'
            ], 404);
        }else{
            return response()->json([
                'message' => 'Menu found',
                'review' => $menu
            ], 200);
        }
    }
}
